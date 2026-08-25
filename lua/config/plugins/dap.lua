-- lua/config/plugins/dap.lua
-- Debugging und Testing: nvim-dap, neotest

-- DAP (Debugging)
local dap = require("dap")
local dapui = require("dapui")

dapui.setup()
require("nvim-dap-virtual-text").setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "DAP: Continue" })
vim.keymap.set("n", "<leader>dn", dap.step_over, { desc = "DAP: Step over" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "DAP: Step into" })
vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "DAP: Step out" })
vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "DAP: Open REPL" })

-- Neotest (Testing)
local neotest = require("neotest")
neotest.setup({
    adapters = {
        require("neotest-vitest"),
        require("neotest-java"),
    },
})

vim.keymap.set("n", "<leader>tt", function()
    neotest.run.run()
end, { desc = "Test: Run nearest test" })
vim.keymap.set("n", "<leader>tf", function()
    neotest.run.run(vim.fn.expand("%"))
end, { desc = "Test: Run file" })
vim.keymap.set("n", "<leader>ts", function()
    neotest.summary.toggle()
end, { desc = "Test: Toggle summary" })
