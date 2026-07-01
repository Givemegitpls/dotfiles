local M = {}

function M.format(_, ctx, input_lines, err_string_cb)
	local text = table.concat(input_lines, "\n")

	if #text == 0 then
		err_string_cb(nil, { "" })
		return
	end

	local urls, n = {}, 0
	local processed = text:gsub("()%[([^%]]+)%]%(([^%)\n]+)%)", function(pos, link_text, url)
		if pos > 1 and text:sub(pos - 1, pos - 1) == "!" then
			return nil
		end
		n = n + 1
		urls[n] = url
		return "[" .. link_text .. "](#R" .. n .. ")"
	end)

	vim.system(
		{
			"prettier",
			"--stdin-filepath",
			ctx.filename or "file.md",
			"--prose-wrap",
			"always",
			"--print-width",
			"80",
		},
		{ stdin = processed, text = true },
		vim.schedule_wrap(function(result)
			if result.code ~= 0 then
				err_string_cb(result.stderr or "prettier failed")
				return
			end

			local restored = 0
			local output = result.stdout:gsub(
				"%[([^%]]+)%]%(#R(%d+)%)",
				function(link_text, idx_str)
					local idx = tonumber(idx_str)
					local url = urls[idx]
					if url then
						restored = restored + 1
						return "[" .. link_text .. "](" .. url .. ")"
					end
				end
			)

			if restored ~= n then
				vim.notify(
					"md_prettier: restored " .. restored .. " of " .. n .. " links",
					vim.log.levels.WARN
				)
			end

			local lines = vim.split(output, "\n")
			if #lines > 1 and lines[#lines] == "" then
				table.remove(lines)
			end
			err_string_cb(nil, lines)
		end)
	)
end

return M
