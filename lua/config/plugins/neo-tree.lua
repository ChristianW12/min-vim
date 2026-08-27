local activeOnEnter = true
-- local activeOnEnter = false

require("neo-tree").setup({
    close_if_last_window = true,
    filesystem = {
        follow_current_file = {
            enabled = true,
        },
        use_libuv_file_watcher = true,
    },
    window = {
        width = 30,
    },
})

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if activeOnEnter and vim.fn.argc() == 0 then
            vim.cmd("Neotree filesystem reveal float")
        end
    end,
    desc = "Open Neo-tree on an empty startup",
})
