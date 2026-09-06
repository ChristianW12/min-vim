-- init.lua
-- Minimale Neovim-Konfiguration ohne lazy.nvim
-- Nutzt vim.pack.add() und natives LSP

-- 1. LEADER KEYS (müssen ganz oben stehen, bevor Plugins geladen werden)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- WINDOWS FIX: GCC bevorzugen statt cl.exe
if vim.fn.has("win32") == 1 then
    vim.env.CC = "gcc"
end

-- LIBUV / FLATPAK FIX: Wenn Neovim in einem FUSE-Mount (z.B. xdg-document-portal wie /run/user/...) startet,
-- schlägt die CWD-Erkennung oft fehl und gibt "" zurück. Das verursacht Abstürze in `vim.fs` und Neo-tree.
-- Wir überladen getcwd() global, um das Arbeitsverzeichnis aus der Shell-Umgebungsvariable zu holen.
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
-- Neue Plugins einfach als weiteren Eintrag in vim.pack.add() ergänzen.
vim.pack.add({
    -- Kern-Abhängigkeiten
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/MunifTanjim/nui.nvim",
    -- Navigation & Suche
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
    "https://github.com/iamcco/markdown-preview.nvim",
    "https://github.com/nvim-telescope/telescope-bibtex.nvim",
    -- Sprach-spezifisch
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
    -- Theme
    "https://github.com/harshrajsachan/omni.nvim",
    "https://github.com/navarasu/onedark.nvim",
    "https://github.com/mofiqul/vscode.nvim",
    "https://github.com/bluz71/vim-moonfly-colors",
})

-- 3. KONFIGURATION LADEN
require("config.options")
require("config.keymaps")
require("config.lsp")
-- 4. PLUGIN-KONFIGURATIONEN LADEN (alle Dateien in lua/config/plugins/)
local plugin_conf_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "config", "plugins")
for _, file in ipairs(vim.fn.readdir(plugin_conf_dir)) do
    if file:match("%.lua$") then
        require("config.plugins." .. file:gsub("%.lua$", ""))
    end
end
