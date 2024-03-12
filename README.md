# NVIM WORKSPACE MANAGER

A single layer implementation.
  
Can be used standalone.
  
Intended usage is with [nvim session manager](https://github.com/The-Plottwist/nvim-session-manager).
  
  
### User Commands:

|Name|Description|
|---|---|
|WorkspaceAdd|Add workspace <br>- Uses directory name if no argument is given|
|WorkspaceDel|Delete workspace|
|WorkspaceList|List workspaces|
|WorkspaceChange*|Change workspace|
|WorkspaceName|Print current workspace name|
|WorkspaceRename|Rename current workspace|
  
*There is an error in lua which calls the internal function ```change_workspace()``` oddly twice, everything works fine on the second call however.
  
### Functions:
|Name|Description|
|---|---|
|add(strName)|Adds a workspace <br>- Optional: *```strName = CURRENT_WORKING_DIRECTORY```*|
|del(strName)|Deletes a workspace <br>- Mandatory: *```strName```* <br>- Returns immidiately if no argument is given|
|list(boolCompletion)|Lists workspaces <br>- Optional: *```boolCompletion = false```* (prints only names instead)|
|rename(strName)|Renames current workspace <br>- Mandatory: *```strName```*|
|change_workspace(strName)|Changes active workspace <br>- Mandatory: *```strName```*|
|is_in_workspace()|Returns a table containing workspace names which has the same path as CWD|
|get_workspace_name(boolPrint)|Returns current workspace name <br>- Optional: *```boolPrint = false```* (prints it instead)|
  
  
### Installation:
Lazy.nvim
```lua
{
    "The-Plottwist/nvim-workspace-manager",
    dependencies = "The-Plottwist/nvim-session-manager", --optional
    branch = "stable"
}
```
  
  
### Defaults:
```lua
defaults = {
    event_hooks = {
        on_add = nil, --calls with arg: workspace name
        on_del = nil, --calls with arg: deleted workspace name
        on_change = nil,
        on_rename = nil,
    }
}
```
  
**Notes**
  
-To modify: *```require("workspace-manager").setup({event_hooks = {on_add = ...,}})```*
  
-Does not load any workspaces by default
  
  
### Example Usage:
With [nvim session manager](https://github.com/The-Plottwist/nvim-session-manager)
```lua
require("session-manager").setup()
require("workspace-manager").setup({
    event_hooks = {
        on_add = function(strName)
            require("session-manager").add(strName)
            end,
        on_del = function(strDeletedWorkspace)
            local cur_workspace = require("workspace-manager").get_workspace_name()
            require("session-manager").change_session(cur_workspace, false)
            require("session-manager").del(strDeletedWorkspace)
        end,
        on_change = function()
            local cur_workspace = require("workspace-manager").get_workspace_name()
            require("session-manager").change_session(cur_workspace)
        end,
        on_rename = function()                                                                                                                                                                                                                           
            local cur_workspace = require("workspace-manager").get_workspace_name()                                                                                                                                                                      
            require("session-manager").rename(cur_workspace)                                                                                                                                                                                             
        end                                                                                                                                                                                                                                              
    }                                                                                                                                                                                                                                                    
})                                                                                                                                                                                                                                                       

--load session if no file is given on vim start                                                                                                                                                                                                          
vim.cmd("let g:ARGC = argc()")                                                                                                                                                                                                                           
if vim.g.ARGC == 0 then                                                                                                                                                                                                                                  

    local workspaces = require("workspace-manager").is_in_workspace()                                                                                                                                                                                    
    if next(workspaces) == nil then                                                                                                                                                                                                                      
        --last session                                                                                                                                                                                                                                   
        require("session-manager").load()                                                                                                                                                                                                                
    else                                                                                                                                                                                                                                                 
        --first workspace                                                                                                                                                                                                                                
        require("workspace-manager").change_workspace(workspaces[1])                                                                                                                                                                                     
    end                                                                                                                                                                                                                                                  
end
```
  