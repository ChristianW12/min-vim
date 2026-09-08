-- lua/config/plugins/editor.lua
-- Kleinere Editor-Plugins: surround, todo-comments, autopairs, autotags, undotree

-- Nvim-Surround
require("nvim-surround").setup({})

-- Todo-Comments
require("todo-comments").setup({})

-- Autopairs (without nvim-cmp integration because native completion is used)
require("nvim-autopairs").setup({
    check_ts = true,
})

-- Autotags
require("nvim-ts-autotag").setup({
    opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = false,
    },
    per_filetype = {},
})

-- Undotree
vim.g.undotree_WindowLayout = 2
vim.g.undotree_SplitWidth = 40
vim.g.undotree_DiffpanelHeight = 12
vim.g.undotree_DiffAutoOpen = 1
vim.g.undotree_SetFocusWhenToggle = 1
vim.g.undotree_ShortIndicators = 1
vim.g.undotree_HelpLine = 1
vim.g.undotree_UndoDir = vim.o.undodir

-- TreesJ
local treesj = require("treesj")
treesj.setup({
    use_default_keymaps = false,
})
vim.keymap.set("n", "<leader>mt", treesj.toggle, { desc = "Toggle Split/Join" })

-- Hlslens
require("hlslens").setup({})
