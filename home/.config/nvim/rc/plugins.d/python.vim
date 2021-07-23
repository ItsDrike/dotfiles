" Define python-specific neomake config
" Neomake is python syntax checker, in this case, we use flake8
" Requires: pip install flake8
let g:neomake_python_enabled_makers = ['flake8']
let g:neomake_python_flake8_maker = {'args': ['--ignore=E501', '--format=default']}
call neomake#configure#automake('nrwi', 500)

" Enable deoplete on startup
" Deoplete provides autosuggestions from python standard library
" Requires: pip install pynvim
let g:deoplete#enable_at_startup = 1

