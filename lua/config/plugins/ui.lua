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
