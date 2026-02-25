-- install theme
if not os.execute("ls $HOME/.config/yazi/theme.toml") then
	os.execute(
		"curl https://raw.githubusercontent.com/catppuccin/yazi/refs/heads/main/themes/mocha/catppuccin-mocha-blue.toml | sed '/\\[app\\]/,+1d' > $HOME/.config/yazi/theme.toml"
	)
end

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
	if handle ~= nil then
		local report = handle:read("*a")
		for _, package in ipairs(packages) do
			install_if_not_exists(package, report)
		end
	end
end
