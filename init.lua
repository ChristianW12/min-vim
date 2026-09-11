-- init.lua
-- Minimal Neovim configuration without lazy.nvim
-- Uses vim.pack.add() and native LSP

-- 1. LEADER KEYS (must be defined before plugins are loaded)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- WINDOWS FIX: GCC bevorzugen statt cl.exe
if vim.fn.has("win32") == 1 then
    vim.env.CC = "gcc"
end

-- LIBUV / FLATPAK FIX: When Neovim starts in a FUSE mount (e.g. xdg-document-portal under /run/user/...),
-- CWD detection often fails and returns "". This causes crashes in `vim.fs` and Neo-tree.
-- Override getcwd() globally to get the working directory from the shell environment variable.
local pwd = os.getenv("PWD") or vim.fn.expand("~")

local original_uv_cwd = vim.uv.cwd
vim.uv.cwd = function()
    local cwd = original_uv_cwd()
    if not cwd or cwd == "" then return pwd end
    return cwd
end

local original_fn_getcwd = vim.fn.getcwd
vim.fn.getcwd = function(winnr, tabnr)
    local cwd
    if winnr and tabnr then
        cwd = original_fn_getcwd(winnr, tabnr)
    elseif winnr then
        cwd = original_fn_getcwd(winnr)
    else
        cwd = original_fn_getcwd()
    end
    if not cwd or cwd == "" then return pwd end
    return cwd
end

-- 2. NATIVES PLUGIN-MANAGEMENT
-- Add new plugins as additional entries in vim.pack.add().
vim.pack.add({
    -- Core dependencies
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/MunifTanjim/nui.nvim",
    -- Navigation & Search
    "https://github.com/nvim-telescope/telescope.nvim",
    "https://github.com/nvim-neo-tree/neo-tree.nvim",
    -- Treesitter
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
    -- Git
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/tpope/vim-fugitive",
    "https://github.com/kdheepak/lazygit.nvim",
    -- Editor-Tools
    "https://github.com/kylechui/nvim-surround",
    "https://github.com/mbbill/undotree",
    "https://github.com/folke/todo-comments.nvim",
    "https://github.com/windwp/nvim-autopairs",
    "https://github.com/windwp/nvim-ts-autotag",
    "https://github.com/folke/which-key.nvim",
    "https://github.com/lukas-reineke/indent-blankline.nvim",
    "https://github.com/Wansmer/treesj",
    "https://github.com/kevinhwang91/nvim-hlslens",
    -- AI
    "https://github.com/github/copilot.vim",
    -- Writing
    "https://github.com/epwalsh/obsidian.nvim",
    "https://github.com/MeanderingProgrammer/render-markdown.nvim",
    "https://github.com/iamcco/markdown-preview.nvim",
    "https://github.com/nvim-telescope/telescope-bibtex.nvim",
    -- Language-specific
    "https://github.com/lervag/vimtex",
    "https://github.com/mfussenegger/nvim-jdtls",
    -- Formatter & Linter
    "https://github.com/stevearc/conform.nvim",
    "https://github.com/mfussenegger/nvim-lint",
    -- DAP
    "https://github.com/mfussenegger/nvim-dap",
    "https://github.com/rcarriga/nvim-dap-ui",
    "https://github.com/theHamsta/nvim-dap-virtual-text",
    "https://github.com/nvim-neotest/nvim-nio",
    -- Testing
    "https://github.com/nvim-neotest/neotest",
    "https://github.com/antoinemadec/FixCursorHold.nvim",
    "https://github.com/marilari88/neotest-vitest",
    "https://github.com/rcasia/neotest-java",
    -- Completion
    "https://github.com/saghen/blink.lib",
    "https://github.com/saghen/blink.cmp",
    -- Theme
    "https://github.com/harshrajsachan/omni.nvim",
    "https://github.com/navarasu/onedark.nvim",
    "https://github.com/mofiqul/vscode.nvim",
    "https://github.com/bluz71/vim-moonfly-colors",
})

-- 3. LOAD CONFIGURATION
require("config.options")
require("config.keymaps")
require("config.lsp")
-- 4. LOAD PLUGIN CONFIGURATIONS (all files in lua/config/plugins/)
local plugin_conf_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "config", "plugins")
for _, file in ipairs(vim.fn.readdir(plugin_conf_dir)) do
    if file:match("%.lua$") then
        require("config.plugins." .. file:gsub("%.lua$", ""))
    end
end
