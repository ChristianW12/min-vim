-- lua/config/plugins/treesitter.lua
require("nvim-treesitter.install").prefer_git = true
require("nvim-treesitter.install").compilers = { "gcc" }

require("nvim-treesitter").setup({
    ensure_installed = {
        "c", "lua", "python", "javascript", "typescript", "html", "css",
        "sql", "angular", "xml", "vim", "bash", "markdown", "java",
        "vimdoc", "query", "markdown_inline",
    },
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        disable = function(_, buf)
            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > 256 * 1024 then return true end
        end,
    },
    indent = {
        enable = true,
    },
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
map("n", "]c", function() move.goto_next_start("@class.outer", "textobjects") end, { desc = "TS: next class" })
map("n", "[c", function() move.goto_previous_start("@class.outer", "textobjects") end, { desc = "TS: prev class" })
