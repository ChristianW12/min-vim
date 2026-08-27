-- lua/config/plugins/writing.lua
-- Writing-Plugins: obsidian, markdown-preview, vimtex

-- Obsidian
require("obsidian").setup({
    workspaces = {
        {
            name = "vault",
            path = function()
                return vim.fn.getcwd()
            end,
        },
    },
    completion = {
        nvim_cmp = false,
        min_chars = 2,
    },
    notes_subdir = "",
    new_notes_location = "notes_subdir",
    disable_frontmatter = true,
    mappings = {
        ["gf"] = {
            action = function()
                return require("obsidian").util.gf_passthrough()
            end,
            opts = { noremap = false, expr = true, buffer = true },
        },
        ["<C-g>"] = {
            action = function()
                return require("obsidian").util.toggle_checkbox()
            end,
            opts = { buffer = true },
        },
    },
    ui = {
        enable = true,
        update_debounce = 200,
        checkboxes = {
            [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
            ["x"] = { char = "", hl_group = "ObsidianDone" },
        },
    },
})

-- Markdown Shortcuts (Buffer-lokal für Markdown)
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.keymap.set("i", "<C-b>", "****<Left><Left>", { desc = "Markdown: Bold", buffer = true })
        vim.keymap.set("i", "<C-u>", "____<Left><Left>", { desc = "Markdown: Underline/Italic", buffer = true })
        vim.keymap.set("i", "<C-g>", function()
            require("obsidian").util.toggle_checkbox()
        end, { desc = "Markdown: Toggle Checkbox", buffer = true })
    end,
})

-- Markdown Preview
vim.g.mkdp_auto_start = 0

-- VimTeX (nur für PA/PA2/BA Ordner)
local folder = vim.fs.basename(vim.fn.getcwd())
if folder == "PA" or folder == "PA2" or folder == "BA" then
    if vim.fn.has("win32") == 1 then
        vim.g.vimtex_view_general_viewer = "SumatraPDF"
        vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"
    elseif vim.fn.has("unix") == 1 then
        vim.g.vimtex_view_method = "zathura"
    end

    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_view_automatic = 1
    vim.g.vimtex_syntax_enabled = 1
end
