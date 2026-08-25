-- lua/config/plugins/ui.lua
-- UI-Plugins: which-key, indent-blankline

-- Which-Key
vim.o.timeout = true
vim.o.timeoutlen = 300

local wk = require("which-key")
wk.setup({
    preset = "modern",
    win = {
        border = "rounded",
    },
})

wk.add({
    { "<leader>f", group = "File Search (Telescope)" },
    { "<leader>b", group = "Buffers/Tabs" },
    { "<leader>l", group = "LSP/Code Help" },
    { "<leader>e", group = "Explorer" },
    { "<leader>g", group = "Git" },
    { "<leader>gh", group = "Git Hunks (Changes)" },
})

-- Indent Blankline
require("ibl").setup({
    indent = {
        char = "│",
        tab_char = "│",
    },
    scope = {
        enabled = true,
        show_start = true,
        show_end = false,
        highlight = { "Function", "Label" },
    },
    exclude = {
        filetypes = {
            "help",
            "dashboard",
            "Trouble",
            "notify",
            "toggleterm",
        },
    },
})
