local has_lazydev, lazydev = pcall(require, "lazydev")
if not has_lazydev then
    return
end

-- lazydev dynamically configures lua_ls for Neovim configs and plugins
lazydev.setup({
    library = {
        -- Loads luvit types when vim.uv is used
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
})
