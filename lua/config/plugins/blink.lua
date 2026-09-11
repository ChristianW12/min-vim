-- lua/config/plugins/blink.lua
-- Autocompletion mit blink.cmp (ersetzt native vim.lsp.completion)

require("blink.cmp").setup({
    keymap = { preset = "default" },
    appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
    },
    completion = {
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
        },
    },
    signature = { enabled = true },
    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
    },
})
