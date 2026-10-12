
require("mini.surround").setup({})
-- - sa (change)
-- - sd (delete)
-- - sr (replace)

require("mini.pairs").setup({})

require("mini.splitjoin").setup({})

require("mini.move").setup({
    mappings = {
        -- Move visual selection in Visual mode
        left = "<A-h>",
        right = "<A-l>",
        down = "<A-j>",
        up = "<A-k>",

        -- Move current line in Normal mode
        line_left = "<A-h>",
        line_right = "<A-l>",
        line_down = "<A-j>",
        line_up = "<A-k>",
    },
})

require("mini.tabline").setup({})

require("mini.starter").setup({})

local indentscope = require("mini.indentscope")
indentscope.setup({
    draw = {
        delay = 0,
        animation = indentscope.gen_animation.none(),
    },
})

require("mini.cursorword").setup({
    delay = 100,
    -- Highlight only on the cursor word
    modes = { "n", "v" },
})
