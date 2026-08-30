-- lua/config/plugins/project.lua
-- Leichtgewichtiger Projekt-Dateipicker ohne Verzeichniswechsel (cwd bleibt unverändert)

local M = {}

-- Speicherort für die Projekthistorie
local history_file = vim.fs.joinpath(vim.fn.stdpath("data"), "project_picker_history.json")

-- Suchmuster für automatische Erkennung
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

-- Projekt-Marker zur Root-Erkennung
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

--- Lädt die gespeicherte Projekthistorie
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

--- Speichert die Projekthistorie in die JSON-Datei
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

--- Fügt ein Projekt an den Anfang der Historie an (MRU)
---@param path string
function M.add_project(path)
    if not path or path == "" then
        return
    end

    -- Pfad normalisieren
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

--- Entfernt ein Projekt aus der Historie
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

--- Scannt vorkonfigurierte Pfade nach Projekten
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
                -- Prüfen, ob es sich um ein Projekt handelt (Marker vorhanden)
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

--- Liefert alle eindeutigen Projekte (Historie zuerst, dann Discovery)
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

--- Öffnet den Telescope Projekt-Picker
function M.open_picker()
    local has_telescope, _ = pcall(require, "telescope")
    if not has_telescope then
        vim.notify("Telescope ist nicht geladen!", vim.log.levels.ERROR)
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
        vim.notify("Keine Projekte gefunden. Öffne zuerst eine Datei in einem Projekt.", vim.log.levels.INFO)
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
        prompt_title = "📁 Projekte (Dateisuche ohne chdir)",
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
            -- ENTER: Dateien aus gewähltem Projekt suchen (cwd bleibt unverändert!)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if not selection then
                    return
                end

                M.add_project(selection.value)

                builtin.find_files({
                    prompt_title = "Dateien in " .. selection.name,
                    cwd = selection.value,
                    hidden = true,
                })
            end)


            -- Ctrl + d: Projekt aus Historie entfernen
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
-- Autocommands zur automatischen Erfassung von Projekten
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

--- Fügt das aktuelle Arbeitsverzeichnis manuell zur Historie hinzu
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
        vim.notify("Verzeichnis ist bereits in der Projektliste: " .. cwd, vim.log.levels.INFO)
        return
    end

    M.add_project(cwd)
    vim.notify("Projekt hinzugefügt: " .. cwd, vim.log.levels.INFO)
end

-- ============================================================================
-- User Commands & Keymaps
-- ============================================================================
vim.api.nvim_create_user_command("ProjectFiles", function()
    M.open_picker()
end, { desc = "Projekt-Dateipicker (ohne chdir)" })

vim.api.nvim_create_user_command("ProjectAddCurrent", function()
    M.add_current_dir()
end, { desc = "Aktuelles Verzeichnis als Projekt hinzufügen" })

vim.keymap.set("n", "<leader>fp", M.open_picker, {
    desc = "Find Project Files (ohne chdir)",
    silent = true,
})

vim.keymap.set("n", "<leader>ap", M.add_current_dir, {
    desc = "Add Current Directory to Projects",
    silent = true,
})

return M
