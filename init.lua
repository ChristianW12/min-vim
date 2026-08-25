-- init.lua
-- Minimale Neovim-Konfiguration ohne lazy.nvim
-- Nutzt vim.pack.add() / packadd und natives LSP

-- 1. LEADER KEYS (müssen ganz oben stehen, bevor Plugins geladen werden)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- WINDOWS FIX: GCC bevorzugen statt cl.exe
if vim.fn.has("win32") == 1 then
    vim.env.CC = "gcc"
end

-- 2. NATIVE PLUGIN BOOTSTRAP
-- Klont fehlende Plugins automatisch per git in das native pack-Verzeichnis
local pack_path = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "plugins", "start")

local function ensure_plugin(repo, name)
    local path = vim.fs.joinpath(pack_path, name)
    if not (vim.uv or vim.loop).fs_stat(path) then
        vim.notify("Klone Plugin: " .. repo, vim.log.levels.INFO)
        vim.fn.system({ "git", "clone", "--depth", "1", "https://github.com/" .. repo, path })
        vim.cmd("packadd " .. name)
    end
end

-- Kern-Abhängigkeiten (von anderen Plugins benötigt)
ensure_plugin("nvim-lua/plenary.nvim", "plenary.nvim")
ensure_plugin("nvim-tree/nvim-web-devicons", "nvim-web-devicons")

-- Navigation & Suche
ensure_plugin("nvim-telescope/telescope.nvim", "telescope.nvim")

-- Treesitter
ensure_plugin("nvim-treesitter/nvim-treesitter", "nvim-treesitter")
ensure_plugin("nvim-treesitter/nvim-treesitter-textobjects", "nvim-treesitter-textobjects")

-- Git
ensure_plugin("lewis6991/gitsigns.nvim", "gitsigns.nvim")
ensure_plugin("tpope/vim-fugitive", "vim-fugitive")
ensure_plugin("kdheepak/lazygit.nvim", "lazygit.nvim")

-- Editor-Tools
ensure_plugin("kylechui/nvim-surround", "nvim-surround")
ensure_plugin("mbbill/undotree", "undotree")
ensure_plugin("folke/todo-comments.nvim", "todo-comments.nvim")
ensure_plugin("windwp/nvim-autopairs", "nvim-autopairs")
ensure_plugin("windwp/nvim-ts-autotag", "nvim-ts-autotag")
ensure_plugin("folke/which-key.nvim", "which-key.nvim")
ensure_plugin("lukas-reineke/indent-blankline.nvim", "indent-blankline.nvim")

-- AI
ensure_plugin("github/copilot.vim", "copilot.vim")

-- Writing
ensure_plugin("epwalsh/obsidian.nvim", "obsidian.nvim")
ensure_plugin("iamcco/markdown-preview.nvim", "markdown-preview.nvim")
ensure_plugin("nvim-telescope/telescope-bibtex.nvim", "telescope-bibtex.nvim")

-- Sprach-spezifisch
ensure_plugin("lervag/vimtex", "vimtex")
ensure_plugin("mfussenegger/nvim-jdtls", "nvim-jdtls")

-- Formatter & Linter
ensure_plugin("stevearc/conform.nvim", "conform.nvim")
ensure_plugin("mfussenegger/nvim-lint", "nvim-lint")

-- DAP (Debugging)
ensure_plugin("mfussenegger/nvim-dap", "nvim-dap")
ensure_plugin("rcarriga/nvim-dap-ui", "nvim-dap-ui")
ensure_plugin("theHamsta/nvim-dap-virtual-text", "nvim-dap-virtual-text")
ensure_plugin("nvim-neotest/nvim-nio", "nvim-nio")

-- Testing
ensure_plugin("nvim-neotest/neotest", "neotest")
ensure_plugin("antoinemadec/FixCursorHold.nvim", "FixCursorHold.nvim")
ensure_plugin("marilari88/neotest-vitest", "neotest-vitest")
ensure_plugin("rcasia/neotest-java", "neotest-java")

-- Theme
ensure_plugin("navarasu/onedark.nvim", "onedark.nvim")

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
