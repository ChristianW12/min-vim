
require("nvim-treesitter.install").prefer_git = true
require("nvim-treesitter.install").compilers = { "gcc" }

local ts = require("nvim-treesitter")
ts.setup({})

local ensure_installed = {
    "c", "lua", "python", "javascript", "typescript", "html", "css",
    "sql", "angular", "xml", "vim", "bash", "markdown", "java",
    "vimdoc", "query", "markdown_inline",
}

-- Automatically install missing parsers
local installed_parsers = ts.get_installed("parsers")
local missing_parsers = vim.tbl_filter(function(lang)
    return not vim.list_contains(installed_parsers, lang)
end, ensure_installed)

if #missing_parsers > 0 then
    ts.install(missing_parsers)
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)

        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
        if ok and stats and stats.size > 1024 * 1024 then
            return
        end

        local filetype = vim.bo[args.buf].filetype
        local lang = vim.treesitter.language.get_lang(filetype) or filetype
        local installed = ts.get_installed("parsers")

        if vim.list_contains(installed, lang) then
            vim.treesitter.start(args.buf)
        end
    end,
})

-- Treesitter Textobjects
local map = vim.keymap.set


-- Textobjects: af/if = function, ac/ic = class, ab/ib = block
local sel = require("nvim-treesitter-textobjects.select")
map({ "x", "o" }, "af", function() sel.select_textobject("@function.outer", "textobjects") end, { desc = "TS: outer function" })
map({ "x", "o" }, "if", function() sel.select_textobject("@function.inner", "textobjects") end, { desc = "TS: inner function" })
map({ "x", "o" }, "ac", function() sel.select_textobject("@class.outer", "textobjects") end, { desc = "TS: outer class" })
map({ "x", "o" }, "ic", function() sel.select_textobject("@class.inner", "textobjects") end, { desc = "TS: inner class" })
map({ "x", "o" }, "ab", function() sel.select_textobject("@block.outer", "textobjects") end, { desc = "TS: outer block" })
map({ "x", "o" }, "ib", function() sel.select_textobject("@block.inner", "textobjects") end, { desc = "TS: inner block" })

-- Navigation: ]f/[f = next/prev function, ]c/[c = next/prev class
local move = require("nvim-treesitter-textobjects.move")
map("n", "]f", function() move.goto_next_start("@function.outer", "textobjects") end, { desc = "TS: next function" })
map("n", "[f", function() move.goto_previous_start("@function.outer", "textobjects") end, { desc = "TS: prev function" })
map("n", "]k", function() move.goto_next_start("@class.outer", "textobjects") end, { desc = "TS: next class" })
map("n", "[k", function() move.goto_previous_start("@class.outer", "textobjects") end, { desc = "TS: prev class" })
