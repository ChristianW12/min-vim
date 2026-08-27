-- lua/config/plugins/project.lua
-- project.nvim: erkennt Projekt-Root automatisch und merkt sich besuchte Projekte

require("project_nvim").setup({
    manual_mode = false,
    detection_methods = { "lsp", "pattern" },
    patterns = { ".git", "package.json", "Makefile", "pyproject.toml" },
    silent_chdir = true,
})

vim.keymap.set("n", "<leader>cp", "<cmd>Telescope projects<CR>", {
    desc = "Change Project",
    silent = true,
})
