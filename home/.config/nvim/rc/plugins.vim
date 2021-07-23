" This file handles plugin management with plug.vim
" It contains an automatic first-time installer for plug.vim and plugins
" It also sources plugin specific config files

" Install plugins automatically
if ! filereadable(config_dir."/autoload/plug.vim")
	echo "Downloading junegunn/vim-plug to manage plugins..."
    let x = system('mkdir -p '.config_dir.'/autoload')
    let x = system('curl https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim > '.config_dir.'/autoload/plug.vim')
	autocmd VimEnter * PlugInstall
endif

" Plug.vim plugin list
call plug#begin(config_dir."/plugged")

" Code completion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Themes
Plug 'tomasiser/vim-code-dark'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'
" Python
Plug 'neomake/neomake'
Plug 'zchee/deoplete-jedi'
" Misc
Plug 'airblade/vim-gitgutter'
Plug 'wakatime/vim-wakatime'
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

call plug#end()


" Source more plugin-specific configuration files from here
let plugins_rc_dir = rc_dir."/plugins.d"
execute "source ".plugins_rc_dir."/airline.vim"
execute "source ".plugins_rc_dir."/nerdtree.vim"
execute "source ".plugins_rc_dir."/python.vim"
