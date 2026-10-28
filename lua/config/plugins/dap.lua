
local dap_initialized = false
local function get_dap()
    local dap = require("dap")
    if not dap_initialized then
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
        dap_initialized = true
    end
    return dap
end

vim.keymap.set("n", "<leader>db", function()
    get_dap().toggle_breakpoint()
    vim.notify("Breakpoint: Toggled", vim.log.levels.INFO)
end, { desc = "DAP: Toggle breakpoint" })
vim.keymap.set("n", "<leader>dc", function() get_dap().continue() end, { desc = "DAP: Continue" })
vim.keymap.set("n", "<leader>dn", function() get_dap().step_over() end, { desc = "DAP: Step over" })
vim.keymap.set("n", "<leader>di", function() get_dap().step_into() end, { desc = "DAP: Step into" })
vim.keymap.set("n", "<leader>do", function() get_dap().step_out() end, { desc = "DAP: Step out" })
vim.keymap.set("n", "<leader>dr", function()
    get_dap().repl.open()
end, { desc = "DAP: Open REPL" })

local neotest_initialized = false
local function get_neotest()
    local neotest = require("neotest")
    if not neotest_initialized then
        neotest.setup({
            adapters = {
                require("neotest-vitest"),
                require("neotest-java"),
            },
        })
        neotest_initialized = true
    end
    return neotest
end

vim.keymap.set("n", "<leader>tt", function()
    get_neotest().run.run()
end, { desc = "Test: Run nearest test" })
vim.keymap.set("n", "<leader>tf", function()
    get_neotest().run.run(vim.fn.expand("%"))
end, { desc = "Test: Run file" })
vim.keymap.set("n", "<leader>ts", function()
    get_neotest().summary.toggle()
    vim.notify("Test Summary: Toggled", vim.log.levels.INFO)
end, { desc = "Test: Toggle summary" })
