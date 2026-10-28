local opt = vim.opt

-- Colorscheme
vim.cmd.colorscheme("onedark")

vim.api.nvim_create_autocmd("OptionSet", {
    group = vim.api.nvim_create_augroup("OneDarkBackground", { clear = true }),
    pattern = "background",
    callback = function()
        if vim.g.colors_name ~= "onedark" then
            return
        end

        require("onedark").setup({ style = vim.o.background })
        vim.cmd.colorscheme("onedark")
    end,
})

-- Basics / UI
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.wrap = false
opt.linebreak = true
opt.breakindent = true
opt.conceallevel = 2 -- Show Obsidian UI (checkboxes, links)
opt.inccommand = "split"
opt.termguicolors = true
opt.winborder = "rounded"

-- resize quickfix list to 15 lines when opened
vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function()
        if vim.bo.filetype == "qf" then
            vim.cmd("resize 15")
        end
    end,
})

-- Preserve context while scrolling
opt.scroll = 5
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Splits: open new windows where expected
opt.splitright = true
opt.splitbelow = true

-- Spell checking (configured per filetype to optimize startup time)
opt.spell = false
opt.spelllang = { "de", "en_us" }

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("SpellChecking", { clear = true }),
    pattern = { "markdown", "text", "gitcommit" },
    callback = function()
        vim.opt_local.spell = true
    end,
})

-- Indentation
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.path:append("**") -- Search across projects with :find

-- Files / Undo / Backup (cross-platform)
opt.undofile = true
local undodir = vim.fs.joinpath(vim.fn.expand("~"), ".vim", "undodir")
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end
opt.undodir = undodir
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.autoread = true

-- Performance / Behavior
opt.updatetime = 300
opt.timeoutlen = 400
opt.mouse = "a"

-- Clipboard
opt.clipboard:append("unnamedplus")

-- Folding (Treesitter-based, replaces UFO)
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = false -- Do not fold when opening
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

opt.fillchars = {
    eob = " ",
    foldopen = "v",
    foldclose = ">",
    foldsep = " ",
    fold = " ",
}

-- Completion
opt.completeopt = { "menu", "menuone", "noselect", "fuzzy" }

-- Built-in statusline (replaces lualine.nvim)
_G.nvim_statusline_git_info = function()
    local errors, warnings = 0, 0
    for _, diagnostic in ipairs(vim.diagnostic.get(0)) do
        if diagnostic.severity == vim.diagnostic.severity.ERROR then
            errors = errors + 1
        elseif diagnostic.severity == vim.diagnostic.severity.WARN then
            warnings = warnings + 1
        end
    end
    local parts = {}
    if errors > 0 then
        parts[#parts + 1] = "E:" .. errors
    end
    if warnings > 0 then
        parts[#parts + 1] = "W:" .. warnings
    end

    local ok, branch = pcall(vim.fn.FugitiveHead)
    if ok and branch ~= "" then
        local git_parts = {}
        local has_changes, changes = pcall(vim.api.nvim_buf_get_var, 0, "gitsigns_status_dict")
        if has_changes and type(changes) == "table" then
            git_parts[#git_parts + 1] = string.format(
                "+%s ~%s -%s",
                tostring(changes.added or 0),
                tostring(changes.changed or 0),
                tostring(changes.removed or 0)
            )
        end

        parts[#parts + 1] = " " .. branch .. (#git_parts > 0 and " │ " .. table.concat(git_parts, " │ ") or "")
    end

    if #parts == 0 then
        return ""
    end

    return table.concat(parts, " │ ") .. " │ "
end

opt.statusline = " %f%h%m%r%=%{v:lua.nvim_statusline_git_info()}%{&filetype} │ %l:%c │ %P "

vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = vim.api.nvim_create_augroup("StatuslineDiagnostics", { clear = true }),
    callback = function()
        vim.cmd("redrawstatus")
    end,
})

-- Netrw configuration (replaces neo-tree)
vim.g.netrw_liststyle = 3 -- Tree view
vim.g.netrw_banner = 0   -- Hide help banner
vim.g.netrw_winsize = 25  -- Window width for Lexplore (25%)

-- Windows terminal / shell configuration
if vim.fn.has("win32") == 1 then
    local powershell_options = {
        shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell",
        shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
        shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait",
        shellpipe = "2>&1 | Out-File -Encoding UTF8 %s",
        shellquote = "",
        shellxquote = "",
    }

    for option, value in pairs(powershell_options) do
        vim.opt[option] = value
    end
end
