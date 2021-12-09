-- Nvim's LSP lacks rename-all functionality which plugins like Coc provide
-- this is a manual implementation of this feature
local vim = require("vim")
local api = vim.api
local cmd = vim.cmd
local lsp = vim.lsp
local fn = vim.fn

local M = {}

-- Unique name for the rename window, so we can access it
-- from close_rename_win function.
local unique_name = "lsp-rename-win"

-- File require string. Neede because we will be defining keymaps
-- applied only to the rename window buffer which will refer to
-- functions within this file, for that, they need to call require
local file_require_string = "lsp.rename"

-- Check whether LSP is actually active.
local function check_lsp_active()
    local active_clients = lsp.get_active_clients()
    if next(active_clients) == nil then
        return false
    end
    return true
end

-- Once in the rename window buffer, apply specific mappings to confirm or
-- cancel renaming, and define a specific autocmd to close the window if
-- we leave it.
local function apply_actions()
    local prefix = string.format("lua require('%s')", file_require_string)
    local close_win_s = prefix .. ".close_rename_win()"
    local do_rename_s = prefix .. ".do_rename()"
    -- Automatically close the window if it's escaped
    api.nvim_command("autocmd QuitPre <buffer> ++nested ++once :silent " .. close_win_s)
    -- Define confirm and exit buffer-specific keymaps
    api.nvim_command("inoremap <buffer><nowait><silent><CR> <cmd>" .. do_rename_s .. "<CR>")
    api.nvim_command("nnoremap <buffer><silent>q <cmd>" .. close_win_s .. "<CR>")
end

-- Closes the rename window (identified by the `unique_name`)
function M.close_rename_win()
    if fn.mode() == "1" then
        cmd[[stopinsert]]
    end

    local exists, winid = pcall(api.nvim_win_get_var, 0, unique_name)
    if exists then
        api.nvim_win_close(winid, true)
    end
end

-- Trigger renaming
function M.do_rename()
    local new_name = vim.trim(fn.getline('.'))
    M.close_rename_win()
    local current_name = fn.expand("<cword>")

    if not new_name or #new_name == 0 or new_name == current_name then
        return
    end

    local params = lsp.util.make_position_params()
    params.newName = new_name
    lsp.buf_request(0, "textDocument/rename", params, function(_, result, _, _)
        if not result then
            -- If the server returns an empty result, don't do anything
            return
        end

        -- The result contains all places we need to update the name
        -- of the identifier, so we apply those edits.
        lsp.util.apply_workspace_edit(result)

        if not result.changes then
            return
        end

        -- Collect amounts of affected files and total renames.
        local total_files = 0
        local total_renames = 0
        for _, renames in pairs(result.changes) do
            total_files = total_files + 1
            for _ in pairs(renames) do
                total_renames = total_renames + 1
            end
        end

        -- Once the changes were applied, these files won't be saved
        -- automatically, let's remind ourselves to save those...
        print(string.format(
            "Changed %s file%s (%s rename%s). To save %s, run ':w%s'",
            total_files,
            total_files > 1 and "s" or "",
            total_renames,
            total_renames > 1 and "s" or "",
            total_files > 1 and "them" or "it",
            total_files > 1 and "a" or ""
        ))
    end)
end

-- Create the rename window
function M.rename()
    if not check_lsp_active() then
        print("No LSP client available, can't rename!")
        return
    end

    -- In case there already is another rename window opened, close it
    M.close_rename_win()


    -- Read the current name here, before we're in the rename window
    local current_name = fn.expand('<cword>')

    -- Create a window within our buffer with our `unique_name` so that it
    -- can be found from the close fucntion and automatically enter it
    local win_opts = {
        relative = 'cursor',
        row = 0,
        col = 0,
        width = 30,
        height = 1,
        style = 'minimal',
        border = 'single'
    }
    local buf = api.nvim_create_buf(false, true)
    local win = api.nvim_open_win(buf, true, win_opts)
    api.nvim_win_set_var(0, unique_name, win)

    -- Automatically enter insert mode
    cmd[[startinsert]]

    -- Pre-write the current name of given object into the rename window
    -- and set cursor behind it
    api.nvim_buf_set_lines(buf, 0, -1, false, {current_name})
    api.nvim_win_set_cursor(win, {1, #current_name})

    -- Set actions for auto-closing the window and buffer-specific mappings
    -- to confirm or close rename
    apply_actions()
end

return M
