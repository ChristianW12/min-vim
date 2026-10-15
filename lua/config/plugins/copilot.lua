
vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true
vim.g.copilot_filetypes = {
    xml = false,
    env = false,
}

vim.keymap.set("i", "<C-a>", 'copilot#Accept("\\<CR>")', {
    expr = true,
    replace_keycodes = false,
    silent = true,
    desc = "Copilot: Accept suggestion",
})

vim.keymap.set("i", "<C-l>", "copilot#AcceptWord()", {
    expr = true,
    replace_keycodes = false,
    silent = true,
    desc = "Copilot: Accept word",
})
