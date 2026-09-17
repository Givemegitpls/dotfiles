-- install plugins
local packages = {
	"yazi-rs/flavors:catppuccin-mocha",
	"yazi-rs/plugins:full-border",
	"boydaihungst/gvfs",
	"XYenon/clipboard",
}

local function install_if_not_exists(package, ya_report)
	local pattern = string.gsub(package, "%p", "%%%1")

	if ya_report:find(pattern) == nil then
		os.execute("ya pkg add" .. " " .. package)
	end
end

do
	local command = "ya pkg list"
	local handle = io.popen(command, "r")
	if handle ~= nil then
		local report = handle:read("*a")
		for _, package in ipairs(packages) do
			install_if_not_exists(package, report)
		end
	end
end

-- Rename plugins via symlinks (yazi plugin name = `plugins/<name>.yazi` entry name).
-- Map: alias = real plugin dir name (as installed by `ya pkg add`, without `.yazi`).
local plugin_aliases = {
	["system-clipboard"] = "clipboard",
}

local function config_home()
	if os.getenv("YAZI_CONFIG_HOME") then
		return os.getenv("YAZI_CONFIG_HOME")
	elseif os.getenv("XDG_CONFIG_HOME") then
		return os.getenv("XDG_CONFIG_HOME") .. "/yazi"
	else
		return os.getenv("HOME") .. "/.config/yazi"
	end
end

local function sh_quote(s)
	return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function apply_plugin_aliases()
	local plugins_dir = config_home() .. "/plugins"

	for alias_name, real_name in pairs(plugin_aliases) do
		os.execute("ln -sfn " .. sh_quote("./" .. real_name .. ".yazi") .. " " .. sh_quote(plugins_dir .. "/" .. alias_name .. ".yazi"))
	end

	local handle = io.popen("ls -1A " .. sh_quote(plugins_dir) .. " 2>/dev/null")
	if handle then
		for name in handle:lines() do
			local entry_alias = name:match("^(.*)%.yazi$")
			if entry_alias and not plugin_aliases[entry_alias] then
				local link = plugins_dir .. "/" .. name
				os.execute("if [ -L " .. sh_quote(link) .. " ]; then rm " .. sh_quote(link) .. "; fi")
			end
		end
		handle:close()
	end
end

apply_plugin_aliases()

require("full-border"):setup()
require("gvfs"):setup({})
