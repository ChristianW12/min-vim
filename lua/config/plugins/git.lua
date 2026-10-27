
local function set_blame_hl()
    if vim.o.background == "light" then
        vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { fg = "#6b7280", italic = true })
    else
        vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { fg = "#8b949e", italic = true })
    end
end

set_blame_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_blame_hl })

require("gitsigns").setup({
    signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "▎" },
    },
    current_line_blame = true,
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 0,
        ignore_whitespace = false,
    },
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigate changes
        map("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
        end, { expr = true, desc = "Next Change" })

        map("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
        end, { expr = true, desc = "Previous Change" })

        -- Git actions
        map("n", "<leader>ghp", gs.preview_hunk, { desc = "Preview Hunk" })

        map("n", "<leader>gd", function()
            local current_tab = vim.api.nvim_get_current_tabpage()
            local gitsigns_win = nil
            local gitsigns_buf = nil

            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tab)) do
                local buf = vim.api.nvim_win_get_buf(win)
                local name = vim.api.nvim_buf_get_name(buf)
                if name:match("^gitsigns://") then
                    gitsigns_win = win
                    gitsigns_buf = buf
                    break
                end
            end

            if gitsigns_win then
                if vim.api.nvim_win_is_valid(gitsigns_win) then
                    vim.api.nvim_win_close(gitsigns_win, true)
                end
                if gitsigns_buf and vim.api.nvim_buf_is_valid(gitsigns_buf) then
                    pcall(vim.api.nvim_buf_delete, gitsigns_buf, { force = true })
                end
                vim.cmd("diffoff!")
                vim.notify("Git Diff: Closed", vim.log.levels.WARN)
            else
                gs.diffthis()
                vim.notify("Git Diff: Open", vim.log.levels.INFO)
            end
        end, { desc = "Toggle Git Diff for current file" })

        map("n", "<leader>ghb", gs.blame, { desc = "Git Blame File" })
        map("n", "<leader>ghs", gs.stage_hunk, { desc = "Stage Hunk" })
        map("n", "<leader>ghu", gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
        map("n", "<leader>ghr", gs.reset_hunk, { desc = "Reset Hunk" })

        map("n", "<leader>tgb", function()
            local enabled = gs.toggle_current_line_blame()
            if enabled then
                vim.notify("Git Blame Virtual Text: ON", vim.log.levels.INFO)
            else
                vim.notify("Git Blame Virtual Text: OFF", vim.log.levels.WARN)
            end
        end, { desc = "Toggle Git Blame Virtual Text" })

        map("n", "<leader>gb", gs.blame_line, { desc = "Git Blame Line" })
        map("n", "<leader>gB", function() 
            gs.blame_line({ full = true }) 
            print "Toggled Inline Git Blame"
        end, { desc = "Git Blame Line (Full)" })
    end,
})

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
