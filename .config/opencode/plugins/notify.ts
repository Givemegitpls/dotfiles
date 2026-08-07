import type { Plugin } from "@opencode-ai/plugin";
import { spawn } from "node:child_process";

// Module-level state so duplicated plugin instances share the same
// notification ID and deduplication set.
let notificationId: string | undefined;
let notifyChain: Promise<void> = Promise.resolve();
const notifiedPermissionIds = new Set<string>();

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

export default (async () => {
  return {
    event: async (input) => {
      const event = input.event as any;

      if (event.type === "permission.asked") {
        const props = event.properties;
        const id = props?.id;
        if (!id || notifiedPermissionIds.has(id)) return;

        notifiedPermissionIds.add(id);
        const type = props?.permission ?? "opencode";
        const metadata = props?.metadata ?? {};
        const pattern =
          metadata.command ??
          metadata.filepath ??
          (props?.patterns?.length ? props.patterns.join(", ") : undefined);

        const body = pattern
          ? `Требуется разрешение: ${type} (${pattern})`
          : `Требуется разрешение: ${type}`;

        await sendNotification(`opencode: ${type}`, body);
        return;
      }

      if (event.type === "permission.replied") {
        const id = event.properties?.permissionID;
        if (id) notifiedPermissionIds.delete(id);
      }
    },

    "tool.execute.before": async (input, output) => {
      if (input.tool !== "question") return;

      const questions: Array<{ header?: string; question?: string }> =
        output.args?.questions ?? [];
      const first = questions[0];
      const header = first?.header ?? "Вопрос";
      const text = first?.question ?? "opencode ждёт вашего ответа";

      await sendNotification(`opencode: ${header}`, text);
    },
  };
}) satisfies Plugin;
