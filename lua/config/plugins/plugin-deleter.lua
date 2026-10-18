local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

--- Retrieves all installed plugins via vim.pack
--- @return vim.pack.PlugData[]
function M.get_installed_plugins()
    -- info = false skips slow Git queries (branches/tags)
    return vim.pack.get(nil, { info = false })
end

-- Backward compatibility with previous naming
M.Get_installed_plugins = M.get_installed_plugins

--- Opens a Telescope picker to delete plugins
--- @param opts? table Optional Telescope configuration options
function M.delete_plugins_picker(opts)
    opts = opts or {}

    local plugins = M.get_installed_plugins()
    if #plugins == 0 then
        vim.notify("No plugins found via vim.pack.", vim.log.levels.WARN)
        return
    end

    -- Sort alphabetically by plugin name
    table.sort(plugins, function(a, b)
        return a.spec.name:lower() < b.spec.name:lower()
    end)

    pickers.new(opts, {
        prompt_title = "Delete Plugins (vim.pack.del)",
        finder = finders.new_table({
            results = plugins,
            entry_maker = function(plugin)
                local name = plugin.spec.name
                local status = plugin.active and "[active]" or "[inactive]"
                local src = plugin.spec.src or plugin.path or ""

                return {
                    value = plugin,
                    display = string.format("%-30s %-12s %s", name, status, src),
                    ordinal = string.format("%s %s", name, src),
                }
            end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local current_picker = action_state.get_current_picker(prompt_bufnr)
                local selections = current_picker:get_multi_selection()

                -- Fallback to currently highlighted entry if no multi-selection via <Tab>
                if vim.tbl_isempty(selections) then
                    local single_entry = action_state.get_selected_entry()
                    if single_entry then
                        table.insert(selections, single_entry)
                    end
                end

                if vim.tbl_isempty(selections) then
                    actions.close(prompt_bufnr)
                    return
                end

                actions.close(prompt_bufnr)

                -- Collect names of plugins to delete
                local names_to_delete = {}
                for _, sel in ipairs(selections) do
                    table.insert(names_to_delete, sel.value.spec.name)
                end

                local prompt_msg = string.format(
                    "Are you sure you want to delete the following plugin(s) from disk?\n- %s\n(y/N): ",
                    table.concat(names_to_delete, "\n- ")
                )

                -- Safety confirmation prompt before deletion
                vim.ui.input({ prompt = prompt_msg }, function(input)
                    if input and input:lower() == "y" then
                        local ok, err = pcall(function()
                            -- force = true allows deleting plugins that are currently active
                            vim.pack.del(names_to_delete, { force = true })
                        end)

                        if ok then
                            vim.notify(
                                string.format("Successfully deleted: %s", table.concat(names_to_delete, ", ")),
                                vim.log.levels.INFO
                            )
                        else
                            vim.notify(
                                string.format("Error deleting plugins: %s", tostring(err)),
                                vim.log.levels.ERROR
                            )
                        end
                    else
                        vim.notify("Deletion cancelled.", vim.log.levels.INFO)
                    end
                end)
            end)
            return true
        end,
    }):find()
end

-- Register Neovim user command
vim.api.nvim_create_user_command("PackDelete", function()
    M.delete_plugins_picker()
end, { desc = "Fuzzy plugin deleter via Telescope and vim.pack.del" })

return M
