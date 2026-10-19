
require("blink.cmp").setup({
    fuzzy = {
        implementation = "prefer_rust",
    },
    keymap = {
        preset = "default",
        ["<C-x><C-o>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-b>"] = {},
        ["<C-f>"] = {},
        ["<C-k>"] = { "scroll_documentation_up" },
        ["<C-j>"] = { "scroll_documentation_down" },
    },
    appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
    },
    completion = {
        menu = {border = "rounded",},
        trigger = {
            show_on_x_blocked_trigger_characters = {},
        },
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
        },
    },
    signature = {
        enabled = true,
        window = {
            border = "rounded",
        },
    },
    sources = {
        default = { "lazydev", "lsp", "omni", "path", "snippets", "buffer" },
        providers = {
            lazydev = {
                name = "LazyDev",
                module = "lazydev.integrations.blink",
                score_offset = 100,
            },
        },
        per_filetype = {
            tex = { "lsp", "omni", "path", "snippets", "buffer" },
            plaintex = { "lsp", "omni", "path", "snippets", "buffer" },
            markdown = { "lsp", "omni", "path", "snippets", "buffer" },
        },
    },
})
