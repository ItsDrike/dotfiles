local vim = require("vim")
local cmd = vim.cmd
local fn = vim.fn

local config_dir = fn.stdpath("config")                 -- Config directory (usually: ~/.config/nvim)
local plugvim_plugins_dir = config_dir .. "/plugged"    -- Dir with all plugins installed by Plug.vim
local plugin_files_dir = config_dir .. "/lua/plugins.d" -- Dir with plugin config files including Plug call(s)

-- Automatically download vimplug and run PlugInstall
local autoload_dir = config_dir .. "/autoload"
local plug_install_path = autoload_dir .. "/plug.vim"
local plug_download_url = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

if fn.empty(fn.glob(plug_install_path)) > 0 then
    print("Downloading vim-plug, there may be initial errors...")
    fn.system({"mkdir", "-p", autoload_dir})
    fn.system("curl " .. plug_download_url .. " > " .. plug_install_path)
    cmd[[autocmd VimEnter * PlugInstall]]
end

-- Load an arbitrary .vim or .lua file
local function load_file(file_path)
    local extension = file_path:match("^.+(%..+)$")
    local run_cmd
    if (extension == ".vim") then run_cmd = "source" else run_cmd = "luafile" end
    fn.execute(run_cmd .. " " .. file_path)
end

-- Load a file containing Plug call(s) and plugin settings
local function load_plugin_file(plugin_file)
    local plugin_path = plugin_files_dir .. "/" .. plugin_file
    load_file(plugin_path)
end

-- Load a single given plugin using a Plug call
local function load_plugin(plugin)
    cmd("Plug '" .. plugin .. "'")
end

-- Begin Plug.vim loading process
cmd("call plug#begin('" .. plugvim_plugins_dir .. "')")

load_plugin('airblade/vim-gitgutter')
load_plugin('dhruvasagar/vim-table-mode')
load_plugin('tmhedberg/SimpylFold')
load_plugin('wakatime/vim-wakatime')
load_plugin('mhinz/vim-startify')
load_plugin('ryanoasis/vim-devicons')
load_plugin_file("vim-code-dark.lua")
load_plugin_file("commentary.lua")
load_plugin_file("coc.vim")
load_plugin_file("vimwiki.lua")
load_plugin_file("nerdtree.lua")
load_plugin_file("airline.lua")
load_plugin_file("fzf.vim")

-- End Plug.vim loading process
cmd[[call plug#end()]]

-- Run autocmds defined in the plugin files after plugin loading has finished
cmd[[doautocmd User PlugLoaded]]
