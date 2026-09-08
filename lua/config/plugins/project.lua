-- lua/config/plugins/project.lua
-- Lightweight project file picker without changing directories (cwd remains unchanged)

local M = {}

-- Project history location
local history_file = vim.fs.joinpath(vim.fn.stdpath("data"), "project_picker_history.json")

-- Search patterns for automatic discovery
local scan_patterns = {
    "~/projects/*",
    "~/.config/*",
    "~/repos/*",
    "~/workspace/*",
    "~/dev/*",
    "~/code/*",
    "~/Coding/*",
    "**/Notizen/*",
    "**/Notes/*",
}

-- Project markers for root detection
local root_markers = {
    ".git",
    "package.json",
    "pyproject.toml",
    "Cargo.toml",
    "pom.xml",
    "build.gradle",
    "Makefile",
    ".root",
}

--- Load the saved project history
---@return string[]
local function load_history()
    local uv = vim.uv or vim.loop
    if not uv.fs_stat(history_file) then
        return {}
    end

    local file = io.open(history_file, "r")
    if not file then
        return {}
    end

    local content = file:read("*a")
    file:close()

    if not content or content == "" then
        return {}
    end

    local ok, parsed = pcall(vim.json.decode, content)
    if ok and type(parsed) == "table" then
        return parsed
    end
    return {}
end

--- Save the project history to the JSON file
---@param projects string[]
local function save_history(projects)
    local file = io.open(history_file, "w")
    if not file then
        return
    end
    local ok, encoded = pcall(vim.json.encode, projects)
    if ok then
        file:write(encoded)
    end
    file:close()
end

--- Add a project to the beginning of the history (MRU)
---@param path string
function M.add_project(path)
    if not path or path == "" then
        return
    end

    -- Normalize path
    local normalized = vim.fs.normalize(path)
    local uv = vim.uv or vim.loop
    local stat = uv.fs_stat(normalized)
    if not stat or stat.type ~= "directory" then
        return
    end

    local history = load_history()
    local new_history = { normalized }

    for _, p in ipairs(history) do
        if p ~= normalized and uv.fs_stat(p) then
            table.insert(new_history, p)
            if #new_history >= 50 then
                break
            end
        end
    end

    save_history(new_history)
end

--- Remove a project from the history
---@param path string
function M.remove_project(path)
    local normalized = vim.fs.normalize(path)
    local history = load_history()
    local new_history = {}

    for _, p in ipairs(history) do
        if p ~= normalized then
            table.insert(new_history, p)
        end
    end

    save_history(new_history)
end

--- Scan preconfigured paths for projects
---@return string[]
local function discover_projects()
    local uv = vim.uv or vim.loop
    local discovered = {}
    local seen = {}

    for _, pattern in ipairs(scan_patterns) do
        local expanded = vim.fn.expand(pattern)
        local matches = vim.fn.glob(expanded, true, true)
        for _, match in ipairs(matches) do
            local norm = vim.fs.normalize(match)
            local stat = uv.fs_stat(norm)
            if stat and stat.type == "directory" and not seen[norm] then
                -- Check whether this is a project (marker present)
                local is_project = false
                for _, marker in ipairs(root_markers) do
                    local marker_path = vim.fs.joinpath(norm, marker)
                    if uv.fs_stat(marker_path) then
                        is_project = true
                        break
                    end
                end

                if is_project then
                    seen[norm] = true
                    table.insert(discovered, norm)
                end
            end
        end
    end

    return discovered
end

--- Return all unique projects (history first, then discovery)
---@return string[]
local function get_all_projects()
    local uv = vim.uv or vim.loop
    local history = load_history()
    local discovered = discover_projects()
    local result = {}
    local seen = {}

    for _, p in ipairs(history) do
        if uv.fs_stat(p) and not seen[p] then
            seen[p] = true
            table.insert(result, p)
        end
    end

    for _, p in ipairs(discovered) do
        if not seen[p] then
            seen[p] = true
            table.insert(result, p)
        end
    end

    return result
end

--- Open the Telescope project picker
function M.open_picker()
    local has_telescope, _ = pcall(require, "telescope")
    if not has_telescope then
        vim.notify("Telescope is not loaded!", vim.log.levels.ERROR)
        return
    end

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local entry_display = require("telescope.pickers.entry_display")
    local builtin = require("telescope.builtin")

    local projects = get_all_projects()
    if #projects == 0 then
        vim.notify("No projects found. Open a file in a project first.", vim.log.levels.INFO)
        return
    end

    local displayer = entry_display.create({
        separator = " ",
        items = {
            { width = 25 },
            { remaining = true },
        },
    })

    local function make_display(entry)
        local home = vim.fs.normalize(vim.fn.expand("~"))
        local display_path = entry.value
        if vim.startswith(display_path, home) then
            display_path = "~" .. display_path:sub(#home + 1)
        end

        return displayer({
            { entry.name, "Directory" },
            { display_path, "Comment" },
        })
    end

    pickers.new({}, {
        prompt_title = "📁 Projects (file search without chdir)",
        finder = finders.new_table({
            results = projects,
            entry_maker = function(path)
                local name = vim.fs.basename(path)
                return {
                    value = path,
                    display = make_display,
                    ordinal = name .. " " .. path,
                    name = name,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            -- ENTER: Find files in the selected project (cwd remains unchanged!)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if not selection then
                    return
                end

                M.add_project(selection.value)

                builtin.find_files({
                    prompt_title = "Files in " .. selection.name,
                    cwd = selection.value,
                    hidden = true,
                })
            end)


            -- Ctrl + d: Remove project from history
            map({ "i", "n" }, "<C-d>", function()
                local selection = action_state.get_selected_entry()
                if selection then
                    M.remove_project(selection.value)
                    actions.close(prompt_bufnr)
                    M.open_picker()
                end
            end)

            return true
        end,
    }):find()
end

-- ============================================================================
-- Autocommands for automatic project tracking
-- ============================================================================
local project_group = vim.api.nvim_create_augroup("ProjectPickerAutoTrack", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
    group = project_group,
    callback = function(args)
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
        if buftype ~= "" then
            return
        end

        local bufname = vim.api.nvim_buf_get_name(args.buf)
        if bufname == "" or not vim.uv.fs_stat(bufname) then
            return
        end

        -- Prevent vim/fs:837 assertion failed when CWD is invalid/deleted
        if not vim.uv.cwd() and not vim.startswith(bufname, "/") and not bufname:match("^%w:[\\/]") then
            return
        end

        local root = vim.fs.root(args.buf, root_markers)
        if root then
            M.add_project(root)
        end
    end,
})

--- Add the current working directory to the history manually
function M.add_current_dir()
    local cwd = vim.fs.normalize(vim.fn.getcwd())
    local history = load_history()
    local exists = false

    for _, p in ipairs(history) do
        if p == cwd then
            exists = true
            break
        end
    end

    if exists then
        vim.notify("Directory is already in the project list: " .. cwd, vim.log.levels.INFO)
        return
    end

    M.add_project(cwd)
    vim.notify("Project added: " .. cwd, vim.log.levels.INFO)
end

-- ============================================================================
-- User Commands & Keymaps
-- ============================================================================
vim.api.nvim_create_user_command("ProjectFiles", function()
    M.open_picker()
end, { desc = "Project file picker (without chdir)" })

vim.api.nvim_create_user_command("ProjectAddCurrent", function()
    M.add_current_dir()
end, { desc = "Add current directory as a project" })

vim.keymap.set("n", "<leader>fp", M.open_picker, {
    desc = "Find Project Files (without chdir)",
    silent = true,
})

vim.keymap.set("n", "<leader>ap", M.add_current_dir, {
    desc = "Add Current Directory to Projects",
    silent = true,
})

return M
