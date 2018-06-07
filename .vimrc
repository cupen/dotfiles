let s:is_windows = has('win32') || has('win64')
let s:is_cygwin = has('win32unix')
let s:is_gui = has("gui_running")

let s:config = {}
let s:config.language=['c', 'python', 'nim', 'rust', 'html', 'javascript', 'go', 'others']
let s:config.language=['others', 'c', 'python', 'go']

" {{{ Functions
function! s:get_dir(dirname, ...)
    let dirpath=expand('~/.vim/' . a:dirname . '/')
        if !isdirectory(expand(dirpath))
            call mkdir(expand(dirpath))
        endif
    return dirpath
endfunction 

function! s:choose_color_scheme(name)
    if a:name == 'molokai'
        colorscheme molokai
    elseif a:name == 'monokai'
        colorscheme monokai
    endif
endfunction 
" }}}
" {{{ Filetype defines
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
autocmd BufNewFile,BufReadPost *.puml set filetype=plantuml
filetype plugin indent on
" }}}
" Basic {{{
set cursorline
set cursorcolumn
let mapleader = ','
set tabstop=4
set shiftwidth=4
set nospell
set wrap
set number
set nocompatible

" 记录上次编辑的位置
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" 共享系统剪贴板（yank的时候同时存储到剪贴板中）。 
if has('unnamedplus')  " When possible use + register for copy-paste
  set clipboard=unnamed,unnamedplus
else         " On mac and Windows, use * register for copy-paste
  set clipboard=unnamed
endif
"}}}
" Encodings {{{
set encoding=utf-8
set termencoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
language messages zh_CN.UTF-8
"}}}
" Fold {{{
set foldmethod=marker
" set foldmethod=syntax
set foldcolumn=0
setlocal foldlevel=0
set foldclose=all " 自动关闭折叠
"}}}
" Plugins  {{{
call plug#begin('~/.vim/plugged')
"{{{ 缩进
Plug 'nathanaelkane/vim-indent-guides'
if s:is_gui
    hi IndentGuidesOdd ctermbg=black
    hi IndentGuidesEven ctermbg=darkgrey
endif
"}}}
" {{{ 自动补全
" Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
" Plug 'ajh17/VimCompletesMe'
"}}}
"{{{ 快速定位/搜索
Plug 'easymotion/vim-easymotion'
map <Leader> <Plug>(easymotion-prefix)

Plug 'Shougo/vimproc.vim', {'do' : 'make'}
Plug 'Shougo/unite.vim'
    let g:unite_prompt='>> '
    let g:unite_data_directory=s:get_dir('unite')
    let g:unite_source_history_yank_enable=1
    let g:unite_source_rec_max_cache_files=5000

    if executable('ag')
        let g:unite_source_grep_command='ag'
        let g:unite_source_grep_default_opts='--nocolor --line-numbers --nogroup -S -C4'
        let g:unite_source_grep_recursive_opt=''
    elseif executable('ack')
        let g:unite_source_grep_command='ack'
        let g:unite_source_grep_default_opts='--no-heading --no-color -C4'
        let g:unite_source_grep_recursive_opt=''
    endif

Plug 'h1mesuke/unite-outline'
"}}}
"{{{ 状态栏
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'bling/vim-bufferline'
let g:airline_powerline_fonts=1
let g:airline#extensions#bufferline#enabled = 1
let g:airline#extensions#tabline#enabled = 0
let g:airline_theme='murmur'   " @see https://github.com/vim-airline/vim-airline/wiki/Screenshots

"}}}
" LSP {{{
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
let g:lsp_async_completion = 1
if executable('clangd')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd']},
        \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
        \ })
endif

if executable('pyls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })
endif

" }}}
"{{{ basic
Plug 'w0rp/ale'
"Plug 'idanarye/vim-vebugger'
" let g:ale_sign_error = '>>'
" let g:ale_sign_warning = '--'

Plug 'airblade/vim-gitgutter'
" Plug 'majutsushi/tagbar', {'on': 'TagbarToggle' }
Plug 'majutsushi/tagbar'
Plug 'godlygeek/tabular'
" Plug 'othree/eregex.vim'
" let g:eregex_default_enable = 1

Plug 'scrooloose/nerdtree', {'on':['NERDTreeToggle','NERDTreeFind']} "{{{
    let NERDTreeShowHidden=1
    let NERDTreeQuitOnOpen=0
    let NERDTreeShowLineNumbers=1
    let NERDTreeChDirMode=0
    let NERDTreeShowBookmarks=1
    let NERDTreeIgnore=['^.git$','^.hg$', '^.svn$']
    let NERDTreeBookmarksFile=s:get_dir('nerdtree') . 'NERDTreeBookmarks'
    " 退出所有buffer时间自动关闭nerd https://github.com/scrooloose/nerdtree/issues/21
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
Plug 'Xuyuanp/nerdtree-git-plugin', {'on':['NERDTreeToggle','NERDTreeFind']} 
"}}}

"}}}
if count(s:config.language, 'others') "{{{
    Plug 'reedes/vim-wheel'
    Plug 'tpope/vim-markdown', { 'for': 'markdown' }
    Plug 'aklt/plantuml-syntax', { 'for': 'platuml' }
endif "}}}
if count(s:config.language, 'python') "{{{
endif
"}}}
if count(s:config.language, 'javascript') "{{{
    Plug 'HerringtonDarkholme/yats.vim'
    Plug 'ryanolsonx/vim-lsp-typescript'
endif "}}}
if count(s:config.language, 'c') "{{{

endif "}}}
if count(s:config.language, 'java') "{{{
endif "}}}
if count(s:config.language, 'rust') "{{{
    Plug 'rust-lang/rust.vim', { 'for': 'rust' }
endif "}}}
" if count(s:config.language, 'nim') "{{{
" Plug "baabelfish/nvim-nim"
" endif "}}}
if count(s:config.language, 'html') "{{{
    Plug 'vim-scripts/HTML-AutoCloseTag'
endif "}}}
if count(s:config.language, 'go') "{{{
    Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
    if executable('go-langserver')
        au User lsp_setup call lsp#register_server({
            \ 'name': 'go-langserver',
            \ 'cmd': {server_info->['go-langserver', '-mode', 'stdio']},
            \ 'whitelist': ['go'],
            \ })
    endif
endif "}}}



Plug 'tomasr/molokai' "{{{
    let g:rehash256 = 1
"}}}
call plug#end()
syntax enable
"}}}
" Whitespace {{{
set backspace=indent,eol,start                      "allow backspacing everything in insert mode
set autoindent                                      "automatically indent to match adjacent lines
set expandtab                                       "spaces instead of tabs
set smarttab                                        "use shiftwidth to enter tabs
let &tabstop=4              "number of spaces per tab for display
let &softtabstop=4          "number of spaces per tab in insert mode
let &shiftwidth=4           "number of spaces when indenting
set list                                            "highlight whitespace
set listchars=tab:│\ ,trail:•,extends:❯,precedes:❮
set shiftround
set linebreak
let &showbreak='↪ '
"}}}
" Searching {{{
set hlsearch                                        "highlight searches
set incsearch                                       "incremental searching
set ignorecase                                      "ignore case for searching
set smartcase                                       "do case-sensitive if there's a capital letter
if executable('ack')
    set grepprg=ack\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow\ $*
    set grepformat=%f:%l:%c:%m
endif
if executable('ag')
    set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
    set grepformat=%f:%l:%c:%m
endif
"}}}
" Key bindings {{{
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
map <C-L> <C-W>l<C-W>_
map <C-H> <C-W>h<C-W>_

nmap <leader>f0 :set foldlevel=0<cr>
nmap <leader>f1 :set foldlevel=1<cr>
nmap <leader>f2 :set foldlevel=2<cr>
nmap <leader>f3 :set foldlevel=3<cr>
nmap <leader>f4 :set foldlevel=4<cr>
nmap <leader>f5 :set foldlevel=5<cr>
nmap <leader>f6 :set foldlevel=6<cr>
nmap <leader>f7 :set foldlevel=7<cr>
nmap <leader>f8 :set foldlevel=8<cr>
nmap <leader>f9 :set foldlevel=9<cr>

noremap j gj
noremap k gk

inoremap <expr><TAB> pumvisible() ? "\<c-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<c-p>" : "\<S-TAB>"

vnoremap <tab> >gv
vnoremap <s-tab> <gv
nnoremap <c-a> ggVG

nnoremap <silent> <F2> :NERDTreeToggle<cr>
nnoremap <silent> <F3> :NERDTreeFind<cr>
nnoremap <silent> <F9> :TagbarToggle<cr>
nnoremap <silent> <F1> :GitGutterToggle<cr>

nnoremap <c-h> :bN<cr>
nnoremap <c-l> :bn<cr>

" nnoremap <silent> <c-p> :Unite file_rec<cr>
nnoremap <silent> <c-p> :Unite -start-insert file_rec/async<cr>
nnoremap <silent> <c-g> :Unite grep:.<cr>
nnoremap <space>s :Unite -quick-match buffer<cr>
nnoremap <space>y :Unite history/yank<cr>
" nnoremap <silent> <c-p> :CtrlP<cr>
nnoremap <silent> <Leader>fu :CtrlPFunky<cr>
nnoremap <silent> <Leader>fU :execute 'CtrlPFunky ' . expand('<cword>')<cr>

nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc':'zo')<cr>  " 折叠开/关
"}}}
" Terminal {{{
if !s:is_gui
    set t_Co=256
endif
" }}}
" GUI {{{
if s:is_gui
    " set width&height
    set columns=128
    set lines=32

    " F4键切换显示/隐藏菜单栏、工具栏。
    " @see http://liyanrui.is-programmer.com/articles/1791/gvim-menu-and-toolbar-toggle.html
    set guioptions-=m
    set guioptions-=T
    map <silent> <F4> :if &guioptions =~# 'T' <Bar>
            \set guioptions-=T <Bar>
            \set guioptions-=m <bar>
        \else <Bar>
            \set guioptions+=T <Bar>
            \set guioptions+=m <Bar>
        \endif<CR>

    " 解决菜单乱码
    source $VIMRUNTIME/delmenu.vim
    source $VIMRUNTIME/menu.vim
    
    " 设置字体
    set guifont=Source_Code_Pro_Medium:h9
endif
" }}}

" set background=dark
call s:choose_color_scheme('molokai')

let g:tagbar_type_markdown = {
    \ 'ctagstype' : 'markdown',
    \ 'kinds' : [
        \ 'h:Heading_L1',
        \ 'i:Heading_L2',
        \ 'k:Heading_L3'
    \ ]
\ }
