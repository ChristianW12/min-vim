
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

require("quicker").setup({
    keys = {
        {
            ">",
            function() require("quicker").expand({before = 2, after = 2, add_to_existing = true}) end,
            desc = "Expand quickfix context",
        },
        {
            "<",
            function() require("quicker").collapse() end,
            desc = "Collapse quickfix context",
        },
    },
})

vim.keymap.set("n", "<leader>q", function()
    require("quicker").toggle()
end, {
desc = "Toggle quickfix",
})
vim.keymap.set("n", "<leader>l", function()
    require("quicker").toggle({ loclist = true })
end, {
desc = "Toggle loclist",
})

require("md-table")
vim.keymap.set("n", "<leader>mt", function()
    vim.cmd("MdTable")
    vim.notify("Markdown Table Mode: Toggled", vim.log.levels.INFO)
end, { desc = "Toggle Markdown Table" })
