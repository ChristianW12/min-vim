
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- setting c compiler for windows 
if vim.fn.has("win32") == 1 then
    vim.env.CC = "gcc"
end

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
    "https://github.com/sindrets/diffview.nvim",

    -- Editor-Tools
    "https://github.com/nvim-mini/mini.nvim",
    "https://github.com/mbbill/undotree",
    "https://github.com/folke/todo-comments.nvim",
    "https://github.com/windwp/nvim-ts-autotag",
    "https://github.com/folke/which-key.nvim",
    "https://github.com/kevinhwang91/nvim-hlslens",
    "https://github.com/freeo/md-table.nvim",
    "https://github.com/hat0uma/csvview.nvim",
    "https://github.com/goolord/alpha-nvim",
    "https://github.com/stevearc/quicker.nvim",

    -- AI
    "https://github.com/github/copilot.vim",

    -- Writing
    "https://github.com/epwalsh/obsidian.nvim",
    "https://github.com/MeanderingProgrammer/render-markdown.nvim",
    "https://github.com/brianhuster/live-preview.nvim", 
    "https://github.com/nvim-telescope/telescope-bibtex.nvim",
    "https://github.com/hedyhli/outline.nvim",

    -- Language-specific

    -- Formatter & Linter
    "https://github.com/stevearc/conform.nvim",
    "https://github.com/mfussenegger/nvim-lint",
    "https://github.com/dhruvasagar/vim-table-mode",

    -- LSP, Tool Management, Completion, Testing
    "https://github.com/folke/lazydev.nvim",
    "https://github.com/williamboman/mason.nvim",
    "https://github.com/saghen/blink.lib",
    "https://github.com/saghen/blink.cmp",
    "https://github.com/mfussenegger/nvim-dap",
    "https://github.com/rcarriga/nvim-dap-ui",
    "https://github.com/theHamsta/nvim-dap-virtual-text",
    "https://github.com/nvim-neotest/nvim-nio",
    "https://github.com/nvim-neotest/neotest",
    "https://github.com/antoinemadec/FixCursorHold.nvim",
    "https://github.com/marilari88/neotest-vitest",
    "https://github.com/rcasia/neotest-java",
    "https://github.com/lervag/vimtex",
    "https://github.com/mfussenegger/nvim-jdtls",

    -- Theme
    "https://github.com/harshrajsachan/omni.nvim",
    "https://github.com/navarasu/onedark.nvim",
    "https://github.com/mofiqul/vscode.nvim",
    "https://github.com/bluz71/vim-moonfly-colors",
})

require("config.options")
require("config.keymaps")
require("config.lsp")

local plugin_conf_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "config", "plugins")
for _, file in ipairs(vim.fn.readdir(plugin_conf_dir)) do
    if file:match("%.lua$") then
        require("config.plugins." .. file:gsub("%.lua$", ""))
    end
end


-- setting local settings, which are not tracked by git
local local_options = vim.fs.joinpath(vim.fn.stdpath("config"), "local_options.lua")
if vim.uv.fs_stat(local_options) then
    local ok, err = pcall(dofile, local_options)
    if not ok then
        vim.notify("Error loading local_options.lua: " .. tostring(err), vim.log.levels.WARN)
    end
end
