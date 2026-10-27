
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

-- Search git commits and copy selected commit hash to system clipboard
local function copy_git_commit()
    local builtin = require("telescope.builtin")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    builtin.git_commits({
        prompt_title = "Git Commits (Enter copies hash)",
        attach_mappings = function(prompt_bufnr, map)
            local function copy_hash()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if selection and selection.value then
                    vim.fn.setreg("+", selection.value)
                    vim.notify("Commit hash copied: " .. selection.value, vim.log.levels.INFO)
                end
            end

            -- Enter in insert and normal mode copies the commit hash
            map("i", "<CR>", copy_hash)
            map("n", "<CR>", copy_hash)
            -- 'y' in normal mode as intuitive vim alternative
            map("n", "y", copy_hash)

            return true
        end,
    })
end

vim.api.nvim_create_user_command("CopyGitCommit", copy_git_commit, {
    desc = "Search git commits and copy selected hash to clipboard",
})

return {
    copy_git_commit = copy_git_commit,
}
