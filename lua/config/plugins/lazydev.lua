local has_lazydev, lazydev = pcall(require, "lazydev")
if not has_lazydev then
    return
end

-- lazydev konfiguriert lua_ls dynamisch für Neovim-Konfigurationen und Plugins
lazydev.setup({
    library = {
        -- Lädt luvit-Typen, wenn vim.uv verwendet wird
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
})
