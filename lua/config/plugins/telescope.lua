-- lua/config/plugins/telescope.lua
require("telescope").setup({
    defaults = {
        file_ignore_patterns = {
            "%.git[/\\]",
            "%.obsidian[/\\]",
            "node_modules[/\\]",
            "%.cache",
            "dist[/\\]",
            "build[/\\]",
            "%.git$",
            "%.angular[/\\]",
        },
        path_file = { "smart" },
        layout_strategy = "horizontal",
        layout_config = { height = 0.95 },
    },
    pickers = {
        find_files = {
            hidden = true,
            no_ignore = true,
        },
    },
})

-- Preview Wrapping
vim.api.nvim_create_autocmd("User", {
    pattern = "TelescopePreviewerLoaded",
    callback = function(args)
        local preview_winid = vim.fn.bufwinid(args.buf)
        if preview_winid == -1 then return end

        vim.api.nvim_set_option_value("wrap", true, { win = preview_winid })
        vim.api.nvim_set_option_value("breakindent", true, { win = preview_winid })
        vim.api.nvim_set_option_value("number", true, { win = preview_winid })

        local preview_path = args.data and args.data.bufname or nil
        local filename = preview_path and vim.fn.fnamemodify(preview_path, ":t")
            or (args.data and args.data.title)
            or ""
        vim.api.nvim_set_option_value("winbar", filename, { win = preview_winid })
    end,
})

-- BibTeX Extension
pcall(function()
    require("telescope").load_extension("bibtex")
end)
