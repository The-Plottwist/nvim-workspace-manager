---@diagnostic disable: undefined-global, unused-local, need-check-nil
-- # ----------------------------------------------------------- #
-- #                  NEOVIM WORKSPACE MANAGER                   #
-- # ----------------------------------------------------------- #

-- # ----------------------- Description ----------------------- #
-- # Light & simple plugin around nvim-session-manager.


local workspaces = {}
local data_file = ""
local cur_workspace = ""
local notif_options = { title = "Workspace Manager" }

--initialize OS specific variables
local is_os_windows = false
local path_seperator = '/'
local function initialize()
    if vim.fn.has("win32") == 1 then
        is_os_windows = true
        path_seperator = '\\'
    end
end
initialize()


local function check_workspace(strName)

    if workspaces[strName] ~= nil then
        return true
    end

    return false
end

local defaults = {

    event_hooks = {
        on_add = nil,
        on_del= nil,
        on_change = nil,
    }
}


local M = {}

local function load()

    local f = io.open(data_file, 'r')
    if f ~= nil then
        local it = nil
        for i in f:lines() do
            it = string.gmatch(i, "([^;]*);")
            workspaces[it()] = it()
        end
        io.close(f)
    end
end

local function save()

    local f = io.open(data_file, 'w')
    if f ~= nil then
        for i,j in pairs(workspaces) do
            f:write(i .. ';' .. tostring(j) .. ";\n")
        end
        io.close(f)
    else
        vim.notify("Cannot open data file", "error", notif_options)
    end
end

function M.is_in_workspace()

    local cur_wd = vim.fn.getcwd()
    for i,j in pairs(workspaces) do
        if cur_wd == j then
            return i
        end
    end

    return false
end

function M.add(strName)

    if (strName == nil) then
        return
    elseif (strName == "") then
        strName = vim.fs.basename(vim.fn.getcwd())
    end

    if check_workspace(strName) then
        vim.notify("Already exists", "error", notif_options)
        return
    end

    workspaces[strName] = vim.fn.getcwd()
    save()
    M.change_workspace(strName)

    --run hook
    if defaults.event_hooks.on_add ~= nil then
        pcall(defaults.event_hooks.on_add)
    end
end

function M.del(strName)

    if (strName == nil) then
        return
    elseif strName == cur_workspace then
        vim.notify("Cannot delete current workspace", "error", notif_options)
        return
    end

    if check_workspace(strName) then
        workspaces[strName] = nil
        save()
    else
        vim.notify("No such workspace", "error", notif_options)
        return
    end

    --run hook
    if defaults.event_hooks.on_del ~= nil then
        pcall(defaults.event_hooks.on_del)
    end
end

function M.list(boolCompletion)
    if boolCompletion == true then
        for i,_ in pairs(workspaces) do
            print(i)
        end
        return
    end

    for i,j in pairs(workspaces) do
        print(i, '=', j)
    end
end

function M.change_workspace(strName)

    if check_workspace(strName) then
        cur_workspace = strName
        vim.cmd("cd " .. workspaces[strName])

        --run hook
        if defaults.event_hooks.on_change ~= nil then
            pcall(defaults.event_hooks.on_change)
        end
        return
    end

    vim.notify("No such workspace", "error", notif_options)
end

function M.rename(strName)

    if cur_workspace == "" then
        vim.notify("Not in workspace", "error", notif_options)
    end

    workspaces[strName] = workspaces[cur_workspace]
    workspaces[cur_workspace] = nil
    cur_workspace = strName
    save()
end


function M.setup(tableOpts)

    --configure defaults
    defaults = vim.tbl_deep_extend("force", {}, defaults, tableOpts or {})

    --configure workspaces
    data_file = vim.fn.stdpath("data") .. path_seperator .. "workspaces"
    load()

    --setup user commands
    vim.cmd([[
        function! WorkspaceList(A,L,P)
            let s = execute('lua require("workspace-manager").list(true)')
            return execute("echon s[1:]")
        endfunction
        command! -nargs=0 WorkspaceList lua require("workspace-manager").list()
        command! -nargs=? WorkspaceAdd lua require("workspace-manager").add(<q-args>)
        command! -nargs=1 -complete=custom,WorkspaceList WorkspaceDel lua require("workspace-manager").del(<q-args>)
        command! -nargs=1 -complete=custom,WorkspaceList WorkspaceRename lua require("workspace-manager").rename(<q-args>)
        command! -nargs=1 -complete=custom,WorkspaceList WorkspaceChange lua require("workspace-manager").change_workspace(<q-args>)
    ]])
end


return M
