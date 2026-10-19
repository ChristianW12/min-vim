
require("todo-comments").setup({})

require("nvim-ts-autotag").setup({
    opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = false,
    },
    per_filetype = {},
})

vim.g.undotree_WindowLayout = 2
vim.g.undotree_SplitWidth = 40
vim.g.undotree_DiffpanelHeight = 12
vim.g.undotree_DiffAutoOpen = 1
vim.g.undotree_SetFocusWhenToggle = 1
vim.g.undotree_ShortIndicators = 1
vim.g.undotree_HelpLine = 1
vim.g.undotree_UndoDir = vim.o.undodir


require("hlslens").setup({})

require("md-table")
vim.keymap.set("n", "<leader>tmt", function()
    vim.cmd("MdTable")
    vim.notify("Markdown Table Mode: Toggled", vim.log.levels.INFO)
end, { desc = "Toggle Markdown Table" })
