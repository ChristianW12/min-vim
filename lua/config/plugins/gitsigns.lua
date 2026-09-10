-- lua/config/plugins/gitsigns.lua
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
        delay = 1000,
        ignore_whitespace = false,
    },
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation durch Changes
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

        -- Git Aktionen
        map("n", "<leader>ghp", gs.preview_hunk, { desc = "Preview Hunk" })
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, { desc = "Git Blame" })
        map("n", "<leader>ghs", gs.stage_hunk, { desc = "Stage Hunk" })
        map("n", "<leader>ghr", gs.reset_hunk, { desc = "Reset Hunk" })
        map("n", "<leader>ghu", gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
        map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "Toggle Git Blame Virtual Text" })
    end,
})
