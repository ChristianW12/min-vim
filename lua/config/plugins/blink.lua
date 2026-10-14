
require("blink.cmp").setup({
    fuzzy = {
        implementation = "prefer_rust",
    },
    keymap = { preset = "default" },
    appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
    },
    completion = {
        trigger = {
            show_on_x_blocked_trigger_characters = {},
        },
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
        },
    },
    signature = { enabled = true },
    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
            tex = { "lsp", "omni", "path", "snippets", "buffer" },
            plaintex = { "lsp", "omni", "path", "snippets", "buffer" },
        },
    },
})
