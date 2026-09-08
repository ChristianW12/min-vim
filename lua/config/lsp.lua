-- lua/config/lsp.lua
-- Native LSP setup without mason.nvim and nvim-lspconfig
-- Uses vim.lsp.config() and vim.lsp.enable() (Neovim 0.11+)

local is_win = vim.fn.has("win32") == 1
local sep = is_win and "\\" or "/"

-- Helper: npm-installed tools often need .cmd on Windows
local function get_cmd(name)
    if is_win and vim.fn.executable(name) ~= 1 and vim.fn.executable(name .. ".cmd") == 1 then
        return name .. ".cmd"
    end
    return name
end

-- =========================
-- Diagnostics State (persistent, cross-platform)
-- =========================
local diagnostics_state_file = vim.fs.joinpath(vim.fn.stdpath("state"), "diagnostics_enabled")
local inlay_hints_state_file = vim.fs.joinpath(vim.fn.stdpath("state"), "inlay_hints_enabled")

local function load_state(file)
    if vim.fn.filereadable(file) == 1 then
        local lines = vim.fn.readfile(file)
        return lines[1] ~= "0"
    end
    return true
end

local function save_state(file, enabled)
    vim.fn.writefile({ enabled and "1" or "0" }, file)
end

-- =========================
-- Diagnostics configuration
-- =========================
vim.diagnostic.config({
    virtual_text = {
        spacing = 4,
        prefix = "●",
    },
    signs = true,
    underline = true,
    update_in_insert = true,
    severity_sort = true,
})
vim.diagnostic.enable(load_state(diagnostics_state_file))

-- =========================
-- LSP keymaps and features (on LspAttach)
-- =========================
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local map = vim.keymap.set
        local opts = { buffer = ev.buf, silent = true }

        map("n", "gd", vim.lsp.buf.definition, opts)
        map("n", "K", vim.lsp.buf.hover, opts)
        map("n", "<leader>rn", vim.lsp.buf.rename, opts)
        map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        map("n", "gr", vim.lsp.buf.references, opts)

        map("n", "<leader>se", vim.diagnostic.open_float, { desc = "Show error message", buffer = ev.buf })
        map("n", "<leader>te", function()
            local enabled = not vim.diagnostic.is_enabled()
            vim.diagnostic.enable(enabled)
            save_state(diagnostics_state_file, enabled)
            if enabled then
                vim.notify("Diagnostics: ON", vim.log.levels.INFO)
            else
                vim.notify("Diagnostics: OFF", vim.log.levels.WARN)
            end
        end, { desc = "Toggle error messages", buffer = ev.buf })

        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        -- Highlight symbols under the cursor
        if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = ev.buf,
                callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = ev.buf,
                callback = vim.lsp.buf.clear_references,
            })
        end

        -- Inlay Hints
        if client and client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(load_state(inlay_hints_state_file), { bufnr = ev.buf })
            map("n", "<leader>th", function()
                local enabled = not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
                vim.lsp.inlay_hint.enable(enabled)
                save_state(inlay_hints_state_file, enabled)
            end, { desc = "Toggle Inlay Hints", buffer = ev.buf })
        end

        -- Enable native autocompletion (replaces nvim-cmp)
        if client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end,
})

-- =========================
-- Language configuration
-- =========================
-- LSP servers that must be available in PATH
local servers = {
    gopls = {
        cmd = { get_cmd("gopls") },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_markers = { "go.work", "go.mod", ".git" },
    },
    lua_ls = {
        cmd = { get_cmd("lua-language-server") },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
        settings = {
            Lua = {
                diagnostics = { globals = { "vim" } },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                },
            },
        },
    },
    pyright = {
        cmd = { get_cmd("pyright-langserver"), "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
        settings = {
            python = {
                analysis = {
                    inlayHints = {
                        variableTypes = true,
                        functionReturnTypes = true,
                        parameterNames = true,
                    },
                },
            },
        },
    },
    clangd = {
        cmd = { get_cmd("clangd") },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_markers = { "compile_commands.json", ".clangd", ".git" },
    },
    vtsls = {
        cmd = { get_cmd("vtsls"), "--stdio" },
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
    },
    html = {
        cmd = { get_cmd("vscode-html-language-server"), "--stdio" },
        filetypes = { "html" },
        root_markers = { "package.json", ".git" },
    },
    cssls = {
        cmd = { get_cmd("vscode-css-language-server"), "--stdio" },
        filetypes = { "css", "scss", "less" },
        root_markers = { "package.json", ".git" },
    },
    sqlls = {
        cmd = { get_cmd("sql-language-server"), "up", "--method", "stdio" },
        filetypes = { "sql", "mysql" },
        root_markers = { ".git" },
    },
    angularls = {
        cmd = { get_cmd("ngserver"), "--stdio", "--tsProbeLocations", "", "--ngProbeLocations", "" },
        filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx" },
        root_markers = { "angular.json", ".git" },
    },
    lemminx = {
        cmd = { get_cmd("lemminx") },
        filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
        root_markers = { ".git" },
    },
    vimls = {
        cmd = { get_cmd("vim-language-server"), "--stdio" },
        filetypes = { "vim" },
        root_markers = { ".git" },
    },
    bashls = {
        cmd = { get_cmd("bash-language-server"), "start" },
        filetypes = { "sh", "bash" },
        root_markers = { ".git" },
    },
    markdown_oxide = {
        cmd = { get_cmd("markdown-oxide") },
        filetypes = { "markdown" },
        root_markers = { ".git" },
    },
}

-- PowerShell Editor Services (useful only on Windows)
if is_win then
    servers.powershell_es = {
        cmd = { get_cmd("powershell-editor-services") },
        filetypes = { "ps1", "psm1", "psd1" },
        root_markers = { ".git" },
    }
end

-- Register and enable servers
for name, config in pairs(servers) do
    -- Enable only when the executable is found in PATH
    local cmd_name = config.cmd and config.cmd[1] or name
    if vim.fn.executable(cmd_name) == 1 then
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
    end
end
