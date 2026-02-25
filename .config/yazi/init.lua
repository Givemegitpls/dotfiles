-- install plugins
local packages = {
	"yazi-rs/plugins:mount",
	"yazi-rs/flavors:catppuccin-mocha",
	"yazi-rs/plugins:full-border",
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

require("full-border"):setup()
