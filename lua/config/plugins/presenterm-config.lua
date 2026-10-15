local presenterm_tags = {
    "<!-- pause -->",
    "<!-- end_slide -->",
    "<!-- new_line -->",
    "<!-- new_lines: 2 -->",
    "<!-- jump_to_middle -->",
    "<!-- column_layout: [1, 2] -->",
    "<!-- column: 0 -->",
    "<!-- reset_layout -->",
    "<!-- incremental_lists: true -->",
    "<!-- incremental_lists: false -->",
    "<!-- no_footer -->",
    "<!-- font_size: 2 -->",
    "<!-- alignment: left -->",
    "<!-- alignment: center -->",
    "<!-- alignment: right -->",
    "<!-- skip_slide -->",
    "<!-- list_item_newlines: 2 -->",
    "<!-- include: file.md -->",
    "<!-- speaker_note: Your note here -->",
    "<!-- snippet_output: identifier -->",
}

local function insert_at_cursor(bufnr, winid, row, col, text)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        vim.notify("Presenterm target buffer is no longer valid", vim.log.levels.WARN)
        return
    end

    local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""
    local updated_line = line:sub(1, col) .. text .. line:sub(col + 1)

    vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, { updated_line })
    if vim.api.nvim_win_is_valid(winid) then
        vim.api.nvim_win_set_cursor(winid, { row, col + #text })
    end
end

local function pick_presenterm_tag()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    local target_bufnr = vim.api.nvim_get_current_buf()
    local target_winid = vim.api.nvim_get_current_win()
    local cursor = vim.api.nvim_win_get_cursor(target_winid)

    pickers
    .new({}, {
        prompt_title = "Presenterm Tags",
        finder = finders.new_table({
            results = presenterm_tags,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)

                if selection then
                    insert_at_cursor(target_bufnr, target_winid, cursor[1], cursor[2], selection.value)
                end
            end)

            return true
        end,
    })
    :find()
end

vim.keymap.set("n", "<leader>ipt", pick_presenterm_tag, {
    desc = "Insert Presenterm Tag",
})
