return {
	"numToStr/Comment.nvim",
	config = function()
		local comment = require("Comment")
		comment.setup({
			opleader = { line = "|" },
		})
	end,
}
