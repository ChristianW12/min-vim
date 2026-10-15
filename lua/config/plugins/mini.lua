
require("mini.tabline").setup({})

-- Dynamically adapt colors to the active theme
local function configure_tabline_colors()
    local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
    local comment = vim.api.nvim_get_hl(0, { name = "Comment" })
    local cursorline = vim.api.nvim_get_hl(0, { name = "CursorLine" })
    local tabline_sel = vim.api.nvim_get_hl(0, { name = "TabLineSel" })

    local bg_editor = normal.bg
    local fg_muted = comment.fg
    local fg_active = normal.fg

    -- Active tab: use CursorLine background (subtly highlighted) or fallback to TabLineSel
    local bg_active = cursorline.bg
    if not bg_active or bg_active == bg_editor then
        bg_active = tabline_sel.bg
    end

    local fg_active_tab = fg_active
    if bg_active == tabline_sel.bg and tabline_sel.fg then
        fg_active_tab = tabline_sel.fg
    end

    -- Inactive buffer: blend seamlessly with the editor background, subtle readable text
    vim.api.nvim_set_hl(0, "MiniTablineHidden", { fg = fg_muted, bg = bg_editor })

    -- Active buffer: clearly highlighted (active background and bold text)
    vim.api.nvim_set_hl(0, "MiniTablineCurrent", { fg = fg_active_tab, bg = bg_active, bold = true })

    -- Buffer in another visible split window
    vim.api.nvim_set_hl(0, "MiniTablineVisible", { fg = fg_active, bg = bg_editor })

    -- Background of the entire tabline
    vim.api.nvim_set_hl(0, "MiniTablineFill", { bg = bg_editor })
end

-- Reapply automatically on theme change
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = configure_tabline_colors,
})

-- Run once on startup
configure_tabline_colors()

require("mini.surround").setup({})
-- - sa (change)
-- - sd (delete)
-- - sr (replace)

require("mini.pairs").setup({})

require("mini.splitjoin").setup({})

require("mini.move").setup({
    mappings = {
        -- Move visual selection in Visual mode
        left = "<A-h>",
        right = "<A-l>",
        down = "<A-j>",
        up = "<A-k>",

        -- Move current line in Normal mode
        line_left = "<A-h>",
        line_right = "<A-l>",
        line_down = "<A-j>",
        line_up = "<A-k>",
    },
})

require("mini.indentscope").setup({
    draw = {
        delay = 0,
        animation = require("mini.indentscope").gen_animation.none(),
    },
})

-- require("mini.cursorword").setup({
--     delay = 100,
--     -- Highlight only on the cursor word
--     modes = { "n", "v" },
-- })

require("mini.jump2d").setup({})

-- mini.sessions
require("mini.sessions").setup({
    -- Automatically save active session on exit
    autowrite = true,
    -- Read default/latest session if Neovim opened without file arguments
    autoread = false,
    -- Allow deleting the currently active session
    force = { delete = true },
})

-- Session management keymaps
vim.keymap.set("n", "<leader>ss", function()
    require("mini.sessions").select("read")
end, { desc = "Select Session" })

vim.keymap.set("n", "<leader>sl", function()
    require("mini.sessions").read()
end, { desc = "Load Latest/Current Session" })

vim.keymap.set("n", "<leader>sw", function()
    local current = vim.v.this_session
    if current and current ~= "" then
        require("mini.sessions").write(nil)
        vim.notify("Session updated: " .. vim.fs.basename(current), vim.log.levels.INFO)
    else
        local default_name = vim.fs.basename(vim.fn.getcwd())
        local name = vim.fn.input("Session Name: ", default_name)
        if name and name ~= "" then
            require("mini.sessions").write(name)
            vim.notify("Session saved: " .. name, vim.log.levels.INFO)
        end
    end
end, { desc = "Save/Update Session" })

vim.keymap.set("n", "<leader>sd", function()
    require("mini.sessions").select("delete", { force = true })
end, { desc = "Delete Session" })

