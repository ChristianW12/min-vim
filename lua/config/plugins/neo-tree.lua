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
        width = 40,
        mappings = {
            ["/"] = "none",
            ["O"] = "open_with_system_app",
        },
    },
    commands = {
        open_with_system_app = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            if vim.ui.open then
                vim.ui.open(path)
            else
                vim.fn.jobstart({ "explorer.exe", path }, { detach = true })
            end
        end,
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
