-- Which-Key
vim.o.timeout = true
vim.o.timeoutlen = 300

local wk = require("which-key")
wk.setup({
    preset = "modern",
    win = {
        border = "rounded",
    },
})

wk.add({
    { "<leader>f", group = "File Search (Telescope)" },
    { "<leader>b", group = "Buffers/Tabs" },
    { "<leader>l", group = "LSP/Code Help" },
    { "<leader>e", group = "Explorer" },
    { "<leader>g", group = "Git" },
    { "<leader>gh", group = "Git Hunks (Changes)" },
    { "<leader>t", group = "Toggle" },
    { "<leader>s", group = "Session / Search" },
})

local csvview_initialized = false
local function get_csvview()
    local csvview = require("csvview")
    if not csvview_initialized then
        csvview.setup({
            parser = {
                comments = { "#", "//" },
                delimiter = {
                    ft = {},
                    fallbacks = { ";", ",", "\t", "|", ":", " " },
                },
            },
            view = {
                display_mode = "border",
            },
            keymaps = {
                textobject_field_inner = { "if", mode = { "o", "x" } },
                textobject_field_outer = { "af", mode = { "o", "x" } },
                jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
                jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
                jump_next_row = { "<Enter>", mode = { "n", "v" } },
                jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
            },
        })
        csvview_initialized = true
    end
    return csvview
end

vim.keymap.set("n", "<leader>tc", function()
    local csvview = get_csvview()
    csvview.toggle()
    if csvview.is_enabled() then
        vim.notify("CSV View: ON", vim.log.levels.INFO)
    else
        vim.notify("CSV View: OFF", vim.log.levels.WARN)
    end
end, { desc = "Toggle CSV View" })

-- Outline.nvim (Lazy loaded)
local outline_initialized = false
local function get_outline()
    local outline = require("outline")
    if not outline_initialized then
        outline.setup({
            width = 50,
        })
        outline_initialized = true
    end
    return outline
end

vim.keymap.set("n", "<leader>to", function()
    local outline = get_outline()
    outline.toggle()
    if outline.is_open() then
        vim.notify("Outline: ON", vim.log.levels.INFO)
    else
        vim.notify("Outline: OFF", vim.log.levels.WARN)
    end
end, { desc = "Toggle Outline" })

-- Data Explorer (Lazy loaded via <leader>fd / <leader>fD)
local function load_data_explorer(cmd)
    vim.pack.add({ "https://github.com/Kyytox/data-explorer.nvim" })

    -- Data Explorer passes fnameescape() output to DuckDB as a SQL path. On
    -- Windows, that adds backslashes before spaces; DuckDB needs SQL-safe paths.
    if vim.fn.has("win32") == 1 then
        local duckdb = require("data-explorer.core.duckdb")
        local state = require("data-explorer.gestion.state")

        local function with_duckdb_path_handling(method)
            local original = duckdb[method]
            duckdb[method] = function(...)
                local fnameescape = vim.fn.fnameescape
                vim.fn.fnameescape = function(path)
                    if path == state.get_state("current_file") then
                        return path:gsub("\\", "/"):gsub("'", "''")
                    end
                    return fnameescape(path)
                end

                local ok, result, err = pcall(original, ...)
                vim.fn.fnameescape = fnameescape
                if not ok then
                    error(result, 0)
                end
                return result, err
            end
        end

        with_duckdb_path_handling("execute_sql_query")
        with_duckdb_path_handling("get_data_pagination")
    end

    require("data-explorer").setup({
        use_storage_duckdb = false,
        limit = 40, -- Maximum number of rows to fetch per page
        layout = "vertical", -- Vertical or ----------
        files_types = {
            parquet = true,
            csv = true,
            tsv = true,
        },

        -- UI/Telescope options
        telescope_opts = {
            layout_strategy = "vertical",
            layout_config = {
                height = 0.7,
                width = 0.9,
                preview_cutoff = 1,
                preview_height = 0.6, -- Used for vertical layout
                preview_width = 0.4, -- Used for horizontal layout
            },
            finder = {
                include_hidden = false, -- Show hidden files
                exclude_dirs = { ".git", "node_modules", "__pycache__", "venv", ".venv", "miniconda3" },
            },
        },

        -- Floating window options for main display windows
        window_opts = {
            border = "rounded",
            max_height_metadata = 0.25,
            max_width_metadata = 0.25,
        },

        -- Query SQL
        query_sql = {
            history_size = 25, -- Number of queries to keep in history
        },

        -- Key mappings
        mappings = {
            quit = "q", -- Close the main UI
            back = "<BS>", -- Go back to file selection
            next_page = "J", -- Next page of data
            prev_page = "K", -- Previous page of data
            focus_meta = "1", -- Focus the metadata window
            focus_data = "2", -- Focus the data window
            toggle_sql = "3", -- Toggle the SQL query window
            rotate_layout = "r", -- Rotate the layout
            execute_sql = "e", -- Execute the SQL query
            prev_history = "<Up>", -- Previous query in history
            next_history = "<Down>", -- Next query in history
        },

        -- Highlight colors
        hl = {
            windows = {
                bg = "#151515",
                fg = "#cdd6f4",
                title = "#D97706",
                footer = "#F87171",
                sql_fg = "#3B82F6",
                sql_bg = "#1e1e2e",
                sql_err_fg = "#EF4444",
                sql_err_bg = "#3b1d2a",
            },
            buffer = {
                hl_enable = true,
                header = "white",
                col1 = "#EF4444",
                col2 = "#3B82F6",
                col3 = "#10B981",
                col4 = "#FBBF24",
                col5 = "#A78BFA",
                col6 = "#06B6D4",
                col7 = "#F59E0B",
                col8 = "#63A5F7",
                col9 = "#22C55E",
            },
        },
    })

    -- Replace proxy keymaps with direct commands now that the plugin is loaded
    vim.keymap.set("n", "<leader>fd", "<cmd>DataExplorer<CR>", { desc = "Data Explorer" })
    vim.keymap.set("n", "<leader>fD", "<cmd>DataExplorerFile<CR>", { desc = "Data Explorer (Current File)" })

    -- Run the triggered command
    vim.cmd(cmd)
end

vim.keymap.set("n", "<leader>fd", function()
    load_data_explorer("DataExplorer")
end, { desc = "Data Explorer" })

vim.keymap.set("n", "<leader>fD", function()
    load_data_explorer("DataExplorerFile")
end, { desc = "Data Explorer (Current File)" })
