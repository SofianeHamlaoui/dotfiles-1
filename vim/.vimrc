"           ██
"           ░░
"  ██    ██ ██ ██████████  ██████  █████
" ░██   ░██░██░░██░░██░░██░░██░░█ ██░░░██
" ░░██ ░██ ░██ ░██ ░██ ░██ ░██ ░ ░██  ░░
"  ░░████  ░██ ░██ ░██ ░██ ░██   ░██   ██
"   ░░██   ░██ ███ ░██ ░██░███   ░░█████
"    ░░    ░░ ░░░  ░░  ░░ ░░░     ░░░░░

scriptencoding utf-8
set noexrc
set secure
set shell=/bin/dash

" Note: Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

if 1
    fun! ProfileStart()
        let l:profile_file = '/tmp/vim.'.getpid().'.profile.txt'
        echom 'Profiling into' l:profile_file
        exec 'profile start '.l:profile_file
        profile! file **
        profile  func *
    endfun
    if get(g:, 'profile')
        call ProfileStart()
    endif
    let g:loaded_getscriptPlugin = 1 " I don't use it
    let g:loaded_2html_plugin    = 1 " 2html is too ugly for me
    let g:loaded_logipat         = 1 " Boolean logic patterns
    let g:loaded_matchparen      = 1 " Don't show matching brackets/parenthesis
    let g:loaded_netrwPlugin     = 1 " Don't use netrw
    let g:loaded_vimballPlugin   = 1 " Don't use legacy vimball
    let g:loaded_tarPlugin       = 1 " Don't use archive-related plugins
    let g:loaded_gzip            = 1 " Don't use archive-related plugins
    let g:loaded_zipPlugin       = 1 " Don't use archive-related plugins
endif

let g:startuptime = reltime()
autocmd VimEnter * let g:startuptime = reltime(g:startuptime)
    \ | redraw
    \ | echomsg 'startuptime: ' . reltimestr(g:startuptime)
if exists('$TMUX')
    let $NVIM_LISTEN_ADDRESS='/home/neg/1st_level/nvim.socket' | let g:nvim_is_started='on'
endif

if has('nvim')
    let g:python_interpreter='python2'
        let &runtimepath = expand('~/.vim/') . ','
        \ . expand('~/.vim/after/') . ',' . &runtimepath
    runtime! plugin/python_setup.vim
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
    let $COLORTERM='truecolor'
    "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
    "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
    " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
    if (has('termguicolors'))
        set termguicolors
    endif
endif

if (!isdirectory(expand('$HOME/.vim/repos/github.com/Shougo/dein.vim')))
    call system(expand('mkdir -p $HOME/.vim/repos/github.com'))
    call system(expand('git clone https://github.com/Shougo/dein.vim $HOME/.vim/repos/github.com/Shougo/dein.vim'))
endif

set runtimepath+=~/.vim/repos/github.com/Shougo/dein.vim/
if dein#load_state(expand('~/.vim/repos'))
    call dein#begin(expand('~/.vim'))
    call dein#load_toml('~/.vim/dein.toml', {'lazy' : 0})
    call dein#load_toml('~/.vim/dein_lazy.toml', {'lazy' : 1})
    call dein#end()
    call dein#save_state()
endif
if dein#check_install()
    call dein#install()
endif

source ~/.vim/02-keymaps.vim
source ~/.vim/03-plugins-config.vim
source ~/.vim/04-autocmds.vim
source ~/.vim/11-vimacs.vim
source ~/.vim/21-langmap.vim
