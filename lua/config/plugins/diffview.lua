local ok, diffview = pcall(require, "diffview")
if not ok then
    return
end

local actions = require("diffview.actions")

diffview.setup({
    diff_binaries = false,
    enhanced_diff_hl = false,
    use_icons = true,
    file_panel = {
        listing_style = "tree",
        tree_options = {
            flatten_dirs = true,
            folder_statuses = "only_folded",
        },
        win_config = {
            position = "left",
            width = 35,
        },
    },
    keymaps = {
        view = {
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
            { "n", "<c-j>", actions.scroll_view(0.25), { desc = "Scroll view down" } },
            { "n", "<c-k>", actions.scroll_view(-0.25), { desc = "Scroll view up" } },
            { "n", "<c-b>", false },
            { "n", "<c-f>", false },
        },
        file_panel = {
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
            { "n", "<c-j>", actions.scroll_view(0.25), { desc = "Scroll view down" } },
            { "n", "<c-k>", actions.scroll_view(-0.25), { desc = "Scroll view up" } },
            { "n", "<c-b>", false },
            { "n", "<c-f>", false },
        },
        file_history_panel = {
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
            { "n", "<c-j>", actions.scroll_view(0.25), { desc = "Scroll view down" } },
            { "n", "<c-k>", actions.scroll_view(-0.25), { desc = "Scroll view up" } },
            { "n", "<c-b>", false },
            { "n", "<c-f>", false },
        },
    },
})

-- User command: Open side-by-side diff for a specific commit
vim.api.nvim_create_user_command("DiffCommit", function(opts)
    local commit = vim.trim(opts.args)
    if commit == "" then
        vim.notify("Please provide a commit hash: :DiffCommit <hash>", vim.log.levels.WARN)
        return
    end
    vim.cmd("DiffviewOpen " .. commit .. "^!")
end, {
    nargs = 1,
    desc = "Open side-by-side diff for a specific commit",
})
