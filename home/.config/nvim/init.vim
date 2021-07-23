" Let init.vim handle sourcing other more specific
" vim configuration files, rather than keeping everything
" in a single huge config file

let config_dir = system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"')
let rc_dir = config_dir.'/rc'
execute 'source '.rc_dir.'/base.vim'
execute 'source '.rc_dir.'/mappings.vim'
execute 'source '.rc_dir.'/abbreviations.vim'
execute 'source '.rc_dir.'/autocmd.vim'
execute 'source '.rc_dir.'/plugins.vim'
" Needs to be below plugins for colorscheme
execute 'source '.rc_dir.'/theme.vim'

