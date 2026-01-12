-- install plugins
local packages = {
	"yazi-rs/plugins:mount",
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
	local report = handle:read("*a")
	local return_status = handle:close()

	for _, package in ipairs(packages) do
		install_if_not_exists(package, report)
	end
end
