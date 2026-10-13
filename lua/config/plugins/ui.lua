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
    { "<leader>t", group = "Toggle" },
})

require("csvview").setup({
    parser = {
        comments = { "#", "//" },
        -- The `ft` mapping (csv -> ",") takes priority over auto-detection,
        -- which forces a comma delimiter even for semicolon-separated files.
        -- Leaving `ft` empty makes csvview fall back to auto-detection, which
        -- already tries ";" among other delimiters and picks the best match.
        delimiter = {
            ft = {},
            fallbacks = { ";", ",", "\t", "|", ":", " " },
        },
    },
    view = {
        -- "border" draws visible column separators, making the table clearly
        -- recognizable (the default "highlight" mode only colors the delimiter).
        display_mode = "border",
    },
    keymaps = {
        textobject_field_inner = { "if", mode = { "o", "x" } },
        textobject_field_outer = { "af", mode = { "o", "x" } },
        jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
        jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
        jump_next_row = { "<Enter>", mode = { "n", "v" } },
        jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
    },
})

vim.keymap.set("n", "<leader>tc", "<cmd>CsvViewToggle<cr>", { desc = "Toggle CSV View" })
