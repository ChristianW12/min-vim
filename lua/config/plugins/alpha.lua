local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Large ASCII logo for Neovim
dashboard.section.header.val = {
    [[███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
    [[████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
    [[██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
    [[██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
    [[██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
    [[╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
}
dashboard.section.header.opts.hl = "AlphaHeader"

-- Project and directory information
local function get_project_info()
    local cwd = vim.fn.getcwd()
    local current_dir = "  DIRECTORY: " .. vim.fn.fnamemodify(cwd, ":t"):upper()
    local full_path = "  PATH:    " .. vim.fn.fnamemodify(cwd, ":~")

    return {
        type = "text",
        val = {
            current_dir,
            "  " .. string.rep("━", #current_dir),
            full_path,
        },
        opts = {
            hl = "Special",
            position = "center",
        },
    }
end

-- Dynamically embed mini.sessions as buttons
local function get_session_buttons()
    local ok, mini_sessions = pcall(require, "mini.sessions")
    if not ok then
        return {}
    end

    if not mini_sessions.detected then
        pcall(mini_sessions.setup, {})
    end

    local sessions = {}
    for name, data in pairs(mini_sessions.detected or {}) do
        table.insert(sessions, { name = name, modify_time = data.modify_time or 0 })
    end

    -- Most recently modified sessions first
    table.sort(sessions, function(a, b)
        return a.modify_time > b.modify_time
    end)

    local shortcuts = { "s", "S", "a", "A", "z" }
    local buttons = {}
    for i, s in ipairs(sessions) do
        if i > 5 then
            break
        end
        local sc = shortcuts[i] or ("s" .. i)
        local txt = string.format("󰆓  %s", s.name)
        local cmd = string.format("<cmd>lua require('mini.sessions').read('%s')<CR>", s.name)
        table.insert(buttons, dashboard.button(sc, txt, cmd))
    end
    return buttons
end

local session_group = {
    type = "group",
    val = function()
        local btns = get_session_buttons()
        if #btns == 0 then
            return {}
        end
        local res = {
            { type = "text", val = "── Sessions ──", opts = { hl = "Title", position = "center" } },
        }
        for _, b in ipairs(btns) do
            table.insert(res, b)
        end
        return res
    end,
    opts = { spacing = 1 },
}

-- Dynamically retrieve recent files (MRU)
local function get_mru_buttons()
    local oldfiles = vim.v.oldfiles or {}
    local cwd = vim.fn.getcwd()
    local files = {}
    local has_devicons, devicons = pcall(require, "nvim-web-devicons")

    for _, file in ipairs(oldfiles) do
        if #files >= 5 then
            break
        end
        if vim.fn.filereadable(file) == 1 then
            local display_name
            if vim.startswith(file, cwd) then
                display_name = file:sub(#cwd + 2)
            else
                display_name = vim.fn.fnamemodify(file, ":~:.")
            end

            local icon = ""
            if has_devicons then
                local ext = vim.fn.fnamemodify(file, ":e")
                local file_icon = devicons.get_icon(vim.fs.basename(file), ext, { default = true })
                if file_icon then
                    icon = file_icon .. " "
                end
            end

            table.insert(files, { path = file, display = icon .. display_name })
        end
    end

    local buttons = {}
    for i, f in ipairs(files) do
        local sc = tostring(i)
        local cmd = string.format("<cmd>edit %s<CR>", vim.fn.fnameescape(f.path))
        table.insert(buttons, dashboard.button(sc, f.display, cmd))
    end
    return buttons
end

local mru_group = {
    type = "group",
    val = function()
        local btns = get_mru_buttons()
        if #btns == 0 then
            return {}
        end
        local res = {
            { type = "text", val = "── Recent Files ──", opts = { hl = "Title", position = "center" } },
        }
        for _, b in ipairs(btns) do
            table.insert(res, b)
        end
        return res
    end,
    opts = { spacing = 1 },
}

-- Quick actions
local actions_group = {
    type = "group",
    val = {
        { type = "text", val = "── Actions ──", opts = { hl = "Title", position = "center" } },
        dashboard.button("f", "󰈞  Find File", "<cmd>Telescope find_files<CR>"),
        dashboard.button("n", "󰈔  New File", "<cmd>ene <BAR> startinsert<CR>"),
        dashboard.button("q", "󰅚  Quit", "<cmd>qa<CR>"),
    },
    opts = { spacing = 1 },
}

-- Configure overall dashboard layout
dashboard.opts.layout = {
    { type = "padding", val = 2 },
    dashboard.section.header,
    { type = "padding", val = 1 },
    get_project_info(),
    { type = "padding", val = 1 },
    session_group,
    { type = "padding", val = 1 },
    mru_group,
    { type = "padding", val = 1 },
    actions_group,
}

dashboard.section.buttons.val = {}
dashboard.section.footer.val = ""

alpha.setup(dashboard.opts)
vim.b.miniindentscope_disable = true
