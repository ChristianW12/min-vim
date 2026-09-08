-- lua/config/options.lua
-- General Neovim settings (copied from the old config and cleaned up for cross-platform use)
local opt = vim.opt

-- =========================
-- Colorscheme
-- =========================
vim.cmd.colorscheme("moonfly") -- Set colorscheme

-- =========================
-- Basics / UI
-- =========================
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.wrap = true
opt.linebreak = true
opt.breakindent = true
opt.conceallevel = 2 -- Show Obsidian UI (checkboxes, links)
opt.inccommand = "split"
opt.cmdheight = 0
opt.termguicolors = true

-- Preserve context while scrolling
opt.scroll = 5
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Splits: open new windows where expected
opt.splitright = true
opt.splitbelow = true

-- =========================
-- Indentation
-- =========================
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.smartindent = true

-- =========================
-- Search
-- =========================
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.path:append("**") -- Search across projects with :find

-- =========================
-- Files / Undo / Backup (cross-platform)
-- =========================
opt.undofile = true
local undodir = vim.fs.joinpath(vim.fn.expand("~"), ".vim", "undodir")
vim.fn.mkdir(undodir, "p")
opt.undodir = undodir
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.autoread = true

-- =========================
-- Performance / Behavior
-- =========================
opt.updatetime = 300
opt.timeoutlen = 400
opt.mouse = "a"

-- =========================
-- Clipboard
-- =========================
opt.clipboard:append("unnamedplus") 

-- =========================
-- Folding (Treesitter-based, replaces UFO)
-- =========================
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

-- =========================
-- Completion
-- =========================
opt.completeopt = { "menu", "menuone", "noselect" }

-- =========================
-- Built-in statusline (replaces lualine.nvim)
-- =========================
opt.statusline = " %f %h%m%r %= %{FugitiveHead() ==# '' ? '' : ' ' . FugitiveHead()} │ %{&filetype} │ %l:%c │ %P "

-- =========================
-- Netrw configuration (replaces neo-tree)
-- =========================
vim.g.netrw_liststyle = 3 -- Tree view
vim.g.netrw_banner = 0   -- Hide help banner
vim.g.netrw_winsize = 25  -- Window width for Lexplore (25%)

-- =========================
-- Windows terminal / shell configuration
-- =========================
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
