-- lua/config/keymaps.lua
-- All keymaps copied from the old config
-- Plugin keymaps (formerly in lazy.nvim keys={}) are centralized here
local map = vim.keymap.set

-- =========================
-- General Mappings
-- =========================
-- Buffer Navigation
map("n", "L", ":bnext<CR>", { desc = "Next buffer", silent = true })
map("n", "H", ":bprevious<CR>", { desc = "Previous buffer", silent = true })
map("n", "<leader>x", ":bd<CR>", { desc = "Close buffer", silent = true })
map("n", "<leader>X", ":bd!<CR>", { desc = "Force close buffer", silent = true })

-- Window Management
map("n", "<leader>sh", ":split<CR>", { desc = "Horizontal Split" })
map("n", "<leader>sv", ":vsplit<CR>", { desc = "Vertical Split" })

-- Scroll and center cursor
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center cursor" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center cursor" })

-- Wrap-aware Bewegung
-- map("n", "j", function()
--     return vim.v.count == 0 and "gj" or "j"
-- end, { expr = true, silent = true, desc = "Down (wrap-aware)" })
-- map("n", "k", function()
--     return vim.v.count == 0 and "gk" or "k"
-- end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

-- Horizontal scrolling
map("n", "+", "10zlzz", { desc = "Scroll right and center cursor" })
map("n", "ü", "10zhzz", { desc = "Scroll left and center cursor" })

-- Search
map("n", "<leader>nh", ":nohl<CR>", { desc = "Remove search highlight", silent = true })

-- Save/close files
map("n", "<leader>w", ":w<CR>", { desc = "Save file", silent = true })
map("n", "<leader>W", ":wa<CR>", { desc = "Save all files", silent = true })
map("n", "<leader>q", ":confirm q<CR>", { desc = "Quit Neovim", silent = true })
map("n", "<leader>Q", ":qall!<CR>", { desc = "Force quit Neovim", silent = true })

-- Copy colorscheme to clipboard
map("n", "<leader>cth", function()
    local name = vim.g.colors_name or vim.cmd("colorscheme")
    vim.fn.setreg("+", name)
    print("Theme '" .. name .. "' copied to clipboard!")
end, { desc = "Copy current colorscheme name to clipboard" })

-- Move lines (Normal mode)
map("n", "<A-j>", ":m .+1<CR>==", { desc = "line down" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "line up" })

-- Move lines (Visual mode)
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "move selected lines down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "move selected lines up" })

-- =========================
-- Completion (LSP / Omni-Completion)
-- =========================
-- Ctrl + Space triggers code completion in Insert mode
map("i", "<C-Space>", "<C-x><C-o>", { desc = "Trigger LSP Completion", silent = true })
map("i", "<C-@>", "<C-x><C-o>", { desc = "Trigger LSP Completion (Terminal Fallback)", silent = true })

-- =========================
-- Explorer 
-- =========================
-- map("n", "<leader>e", ":Lexplore<CR>", { desc = "Toggle Explorer", silent = true })
-- map("n", "<leader>fe", ":Lexplore<CR>", { desc = "Focus Explorer", silent = true })
-- map("n", "<leader>E", ":Lexplore<CR>", { desc = "Toggle file explorer", silent = true })
map("n", "<leader>e", "<cmd>Neotree toggle filesystem reveal left<CR>", { desc = "Toggle Explorer", silent = true, })

map("n", "<leader>fe", "<cmd>Neotree focus filesystem left<CR>", { desc = "Focus Explorer", silent = true, })

map("n", "<leader>E", "<cmd>Neotree filesystem reveal float<CR>", { desc = "Floating Explorer", silent = true, })

-- =========================
-- Telescope keymaps (formerly in lazy keys={})
-- =========================
map("n", "ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("n", "fg", "<cmd>Telescope live_grep<cr>", { desc = "Search Text (Grep)" })
map("n", "fb", "<cmd>Telescope buffers<cr>", { desc = "Search Open Buffers" })
map("n", "fh", "<cmd>Telescope help_tags<cr>", { desc = "Search Neovim Help" })
map("n", "fr", "<cmd>Telescope lsp_references<cr>", { desc = "Search LSP References" })

-- Find config files (cross-platform)
map("n", "<leader>fc", function()
    require("telescope.builtin").find_files({
        search_dirs = {
            vim.fn.stdpath("config"),
            vim.fs.joinpath(vim.fn.expand("~"), ".contacts.md"),
        },
    })
end, { desc = "Find Config Files" })

map("n", "<leader>TH", "<cmd>Telescope colorscheme enable_preview=true<cr>", { desc = "Colorscheme Preview" })

-- Git Telescope Pickers
map("n", "<leader>ghs", "<cmd>Telescope git_status<cr>", { desc = "Git Status (Telescope)" })
map("n", "<leader>gf", "<cmd>Telescope git_files<cr>", { desc = "Git Files" })
map("n", "<leader>ghc", "<cmd>Telescope git_commits<cr>", { desc = "Git Commits" })
map("n", "<leader>ghB", "<cmd>Telescope git_branches<cr>", { desc = "Git Branches" })

-- Open file externally (cross-platform)
map("n", "<leader>oe", function()
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    require("telescope.builtin").find_files({
        prompt_title = "Open File Externally",
        attach_mappings = function(prompt_bufnr, _)
            local function open_externally()
                local selection = action_state.get_selected_entry()
                if selection ~= nil then
                    actions.close(prompt_bufnr)
                    local file_path = selection.path or selection[1]
                    local full_path = vim.fn.fnamemodify(file_path, ":p")
                    if vim.ui.open then
                        vim.ui.open(full_path)
                    else
                        vim.fn.jobstart({ "explorer.exe", full_path }, { detach = true })
                    end
                end
            end
            map("i", "<CR>", open_externally)
            map("n", "<CR>", open_externally)
            return true
        end,
    })
end, { desc = "Search and Open File Externally" })

-- Outline replaced by Telescope LSP symbols
map("n", "<leader>to", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Document Symbols (Outline)" })

-- Buffer selection (replaces Bufferline keymaps)
map("n", "<leader>bs", "<cmd>Telescope buffers<cr>", { desc = "Select buffer" })
map("n", "<leader>bc", ":bd<CR>", { desc = "Close buffer", silent = true })

-- =========================
-- Mail Contacts (Telescope Custom Picker)
-- =========================
map("n", "<leader>mc", function()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    local contacts_file = vim.fn.expand("~/.contacts.md")
    local contacts = {}
    local file = io.open(contacts_file, "r")
    if not file then
        print("Contacts file not found: " .. contacts_file)
        return
    end
    for line in file:lines() do
        if line:match("%S") then
            table.insert(contacts, line)
        end
    end
    file:close()

    pickers.new({}, {
        prompt_title = "Mail Contacts",
        finder = finders.new_table({ results = contacts }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    vim.api.nvim_put({ selection.value }, "c", false, true)
                end
            end)
            return true
        end,
    }):find()
end, { desc = "Insert Mail Contacts" })

-- =========================
-- Fugitive keymaps (formerly in lazy keys={})
-- =========================
map("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git Status" })
map("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Git Commit" })
map("n", "<leader>gca", "<cmd>Git commit --amend<cr>", { desc = "Git Commit Amend" })
map("n", "<leader>gP", "<cmd>Git push<cr>", { desc = "Git Push" })
map("n", "<leader>gp", "<cmd>Git pull<cr>", { desc = "Git Pull" })
map("n", "<leader>gd", "<cmd>Gvdiffsplit<cr>", { desc = "Git Diff Vertical Split" })
map("n", "<leader>gb", "<cmd>Git blame<cr>", { desc = "Git Blame (Fugitive)" })
map("n", "<leader>gm", function()
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    require("telescope.builtin").git_branches({
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    vim.cmd("Git merge " .. selection.value)
                end
            end)
            return true
        end,
    })
end, { desc = "Git Merge (select branch)" })

-- =========================
-- LazyGit Keymaps
-- =========================
map("n", "<leader>lg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
map("n", "<leader>lf", "<cmd>LazyGitCurrentFile<cr>", { desc = "LazyGit Current File" })

-- =========================
-- Todo-Comments Keymaps
-- =========================
map("n", "<leader>st", "<cmd>TodoTelescope<cr>", { desc = "Todos: all keywords" })
map("n", "<leader>sT", "<cmd>TodoTelescope keywords=TODO,NOTE<cr>", { desc = "Todos: only TODO/NOTE" })

-- =========================
-- Undotree Keymaps
-- =========================
map("n", "<leader>u", "<cmd>UndotreeToggle<CR>", { desc = "Undo Tree Toggle" })
map("n", "<leader>uf", "<cmd>UndotreeFocus<CR>", { desc = "Undo Tree Focus" })

-- =========================
-- Copilot Keymaps
-- =========================
-- (set in config/plugins.lua after plugin setup)

-- =========================
-- Markdown Preview
-- =========================
map("n", "<leader>mp", ":MarkdownPreview<CR>", { noremap = true, silent = true, desc = "Preview of current file in Browser" })
map("n", "<leader>mps", ":MarkdownPreviewStop<CR>", { noremap = true, silent = true, desc = "Stop Markdown Preview" })

-- =========================
-- Obsidian Keymaps (Global triggers)
-- =========================
map("n", "<leader>os", "<cmd>ObsidianSearch<cr>", { desc = "Obsidian: Search text" })
map("n", "<leader>oq", "<cmd>ObsidianQuickSwitch<cr>", { desc = "Obsidian: Quick switch note" })
map("n", "<leader>on", "<cmd>ObsidianNew<cr>", { desc = "Obsidian: New note" })
map("v", "<leader>ol", "<cmd>ObsidianLink<cr>", { desc = "Obsidian: Create link (selection)" })
map("v", "<leader>on", "<cmd>ObsidianNewFromLink<cr>", { desc = "Obsidian: Create note from link" })
map("n", "<leader>od", "<cmd>ObsidianToday<cr>", { desc = "Obsidian: Today (daily note)" })
map("n", "<leader>ot", "<cmd>ObsidianTags<cr>", { desc = "Obsidian: Search tags" })
map("n", "<leader>ob", "<cmd>ObsidianBacklinks<cr>", { desc = "Obsidian: Show backlinks" })
map("n", "<leader>oo", "<cmd>ObsidianOpen<cr>", { desc = "Obsidian: Open vault" })

-- =========================
-- Terminal Mappings
-- =========================
vim.api.nvim_create_autocmd("FileType", {
    pattern = "lazygit",
    callback = function(args)
        pcall(vim.keymap.del, "t", "<Esc>", { buffer = args.buf })
    end,
})

vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    callback = function(args)
        local buf = args.buf
        local name = vim.api.nvim_buf_get_name(buf)
        local is_lazygit = vim.bo[buf].filetype == "lazygit" or name:lower():match("lazygit") ~= nil

        if not is_lazygit then
            map("t", "<Esc>", "<C-\\><C-n>", {
                buffer = buf,
                desc = "Exit terminal mode",
                silent = true,
            })
        end
    end,
})

-- =========================
-- Enterprise Angular + Java Commands
-- =========================
vim.api.nvim_create_user_command("NgServe", function()
    vim.cmd("split | terminal ng serve")
end, { desc = "Angular: Start dev server" })

vim.api.nvim_create_user_command("NgGenerateComponent", function(opts)
    vim.cmd("split | terminal ng generate component " .. opts.args)
end, { desc = "Angular: Generate component", nargs = 1 })

vim.api.nvim_create_user_command("MavenTest", function()
    vim.cmd("split | terminal mvn test")
end, { desc = "Java: Run Maven tests" })

vim.api.nvim_create_user_command("MavenPackage", function()
    vim.cmd("split | terminal mvn clean package")
end, { desc = "Java: Build Maven package" })

vim.api.nvim_create_user_command("GradleBuild", function()
    vim.cmd("split | terminal gradle build")
end, { desc = "Java: Run Gradle build" })

vim.api.nvim_create_user_command("GradleTest", function()
    vim.cmd("split | terminal gradle test")
end, { desc = "Java: Run Gradle tests" })

-- PowerShell start script (cross-platform: relevant only on Windows)
local function project_root_from_git()
    local current_file = vim.api.nvim_buf_get_name(0)
    local start_path = current_file ~= "" and vim.fs.dirname(current_file) or vim.fn.getcwd()
    local git_dir = vim.fs.find(".git", { path = start_path, upward = true })[1]
    if git_dir then
        return vim.fs.dirname(git_dir)
    end
    return vim.fn.getcwd()
end
