-- lua/config/options.lua
-- Allgemeine Neovim-Einstellungen (1:1 aus der alten Config übernommen, cross-platform bereinigt)
local opt = vim.opt

-- =========================
-- Colorscheme
-- =========================
vim.cmd.colorscheme("moonfly") -- Colorscheme setzen

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
opt.conceallevel = 2 -- Obsidian UI (Checkboxes, Links) anzeigen
opt.inccommand = "split"

-- Kontext beim Scrollen beibehalten
opt.scroll = 5
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Splits: neue Fenster dort wo man sie erwartet
opt.splitright = true
opt.splitbelow = true

-- =========================
-- Einrückung
-- =========================
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.smartindent = true

-- =========================
-- Suche
-- =========================
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.path:append("**") -- Projektübergreifende Suche mit :find

-- =========================
-- Dateien / Undo / Backup (Cross-Platform)
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
-- Performance / Verhalten
-- =========================
opt.updatetime = 300
opt.timeoutlen = 400
opt.mouse = "a"

-- =========================
-- Clipboard
-- =========================
opt.clipboard:append("unnamedplus") 

-- =========================
-- Folding (Treesitter-basiert, ersetzt UFO)
-- =========================
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = false -- Folds beim Öffnen nicht einklappen
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
-- Built-in Statusline (ersetzt lualine.nvim)
-- =========================
opt.statusline = " %f %h%m%r %= %{FugitiveHead() ==# '' ? '' : ' ' . FugitiveHead()} │ %{&filetype} │ %l:%c │ %P "

-- =========================
-- Netrw Konfiguration (ersetzt neo-tree)
-- =========================
vim.g.netrw_liststyle = 3 -- Baumansicht
vim.g.netrw_banner = 0   -- Hilfe-Banner ausblenden
vim.g.netrw_winsize = 25  -- Fensterbreite für Lexplore (25%)

-- =========================
-- Windows Terminal / Shell Konfiguration
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
