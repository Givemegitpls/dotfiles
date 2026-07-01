local M = {}

local function is_table_sep(line)
	return line:match("^%s*|?%s*:?%-+:?%s*|") ~= nil
end

local function is_table_row(line)
	return line:match("|.+|") ~= nil
end

local function extract_tables(text)
	local lines = vim.split(text, "\n")
	local result, tables, n = {}, {}, 0
	local i = 1

	while i <= #lines do
		if is_table_row(lines[i]) then
			local has_sep = false
			for j = i, math.min(i + 3, #lines) do
				if is_table_sep(lines[j]) then
					has_sep = true
					break
				end
			end
			if has_sep then
				local start_i = i
				while i <= #lines and is_table_row(lines[i]) do
					i = i + 1
				end
				n = n + 1
				local block = {}
				for k = start_i, i - 1 do
					block[#block + 1] = lines[k]
				end
				tables[n] = table.concat(block, "\n")
				result[#result + 1] = "<!--TBL" .. n .. "-->"
			else
				result[#result + 1] = lines[i]
				i = i + 1
			end
		else
			result[#result + 1] = lines[i]
			i = i + 1
		end
	end

	return table.concat(result, "\n"), tables
end

function M.format(_, ctx, input_lines, err_string_cb)
	local text = table.concat(input_lines, "\n")

	if #text == 0 then
		err_string_cb(nil, { "" })
		return
	end

	local tables = {}
	text, tables = extract_tables(text)

	local urls, n = {}, 0
	text = text:gsub("()%[([^%]]+)%]%(([^%)\n]+)%)", function(pos, link_text, url)
		if pos > 1 and text:sub(pos - 1, pos - 1) == "!" then
			return nil
		end
		n = n + 1
		urls[n] = url
		return "[" .. link_text .. "](#R" .. n .. ")"
	end)

	for i = 1, #tables do
		text = text:gsub("<!%-%-TBL" .. i .. "%-%->", tables[i], 1)
	end

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
		{ stdin = text, text = true },
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
