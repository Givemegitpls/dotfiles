import { spawn } from "node:child_process";

// Module-level state so duplicated plugin instances share the same
// notification ID.
let notificationId: string | undefined;
let notifyChain: Promise<void> = Promise.resolve();

function runNotifySend(args: string[]): Promise<string | undefined> {
  return new Promise((resolve) => {
    const child = spawn("notify-send", args, {
      detached: true,
      stdio: ["ignore", "pipe", "ignore"],
    });

    let stdout = "";
    child.stdout?.on("data", (data: Buffer) => {
      stdout += data.toString("utf8");
    });
    child.on("error", () => resolve(undefined));
    child.on("close", () => {
      const id = stdout.trim();
      resolve(id || undefined);
    });
  });
}

async function sendNotificationImpl(title: string, body: string) {
  const args = ["-a", "opencode"];
  if (notificationId) {
    args.push("--replace-id", notificationId);
  } else {
    args.push("--print-id");
  }
  args.push(title, body);

  const returnedId = await runNotifySend(args);
  if (returnedId) {
    notificationId = returnedId;
  }
}

function sendNotification(title: string, body: string) {
  notifyChain = notifyChain
    .then(() => sendNotificationImpl(title, body))
    .catch(() => {
      // Notification failures should not break the assistant.
    });
  return notifyChain;
}

export default {
  id: "notify",
  async setup(ctx: any) {
    const permissionRegistration = await ctx.permission.hook(
      "evaluate",
      async (event) => {
        if (event.effect !== "ask") return;

        const resources = event.resources.length
          ? event.resources.join(", ")
          : undefined;
        const body = resources
          ? `Требуется разрешение: ${event.action} (${resources})`
          : `Требуется разрешение: ${event.action}`;

        await sendNotification(`opencode: ${event.action}`, body);
      },
    );

    const toolRegistration = await ctx.tool.hook("execute.before", (event) => {
      if (event.tool !== "question") return;

      const questions: Array<{ header?: string; question?: string }> =
        (event.input as any)?.questions ?? [];
      const first = questions[0];
      const header = first?.header ?? "Вопрос";
      const text = first?.question ?? "opencode ждёт вашего ответа";

      return sendNotification(`opencode: ${header}`, text);
    });

    return async () => {
      await permissionRegistration.dispose();
      await toolRegistration.dispose();
    };
  },
};
