"----------- INITIALIZATION: This needs to be at the top of .vimrc ------------------
" pathogen allows you to manage your plugins and runtime files in their own private directories
" http://www.vim.org/scripts/script.php?script_id=2332
"
" Adding a module is as simple as unzipping the module inside .vim/bundle/[module_name]
" or if you use git
"
" git submodule add http://github.com/user/module_name.git bundle/[module_name]

filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" Reset vim defaults (set compatible will make vim behave more like vi)
set nocompatible
filetype on

" Set personal mapping character (used in other remappings further below)
let mapleader = ","
"------------------------------------------------------------------------------------

"##### HISTORY ########################################

" Number of undos to save
set history=500


"##### ERRORS ########################################

" Hide error sound/visual error notification
"set noerrorbells
set novisualbell


"##### EDITING #######################################

" Set backspace behavior (so it can backspace over auto-indent, newline, etc.
" Use this for vim 5.4 or earlier: set backspace=2
set backspace=indent,eol,start

" replace tabs with spaces
set expandtab

" use 4 spaces to represent a tab
set tabstop=4
set softtabstop=4

" use 4 spaces for auto indent (use >> or << to indent current line)
set shiftwidth=4

" indent new line based on current line's indentation
set autoindent

" toggle paste mode (for pasting external code without indentation)
map <Leader>p :set invpaste<CR>

" when using <Ctrl+N>/<Ctrl+P> for command completion, see what your other options are there
set wildmenu

" remap Ctrl+A and Ctrl+X to +/- for easy increment/decrement of numbers
nnoremap + <c-a>
nnoremap - <c-x>

"----- AUTO COMPLETION ----------------------------
" remap Ctrl-X to Ctrl-K because the first combination is too hard to use effectively
imap <c-k> <c-x>

" Note: to use these omnicomplete functions, use Ctrl-k, Ctrl-o, then Ctrl-o again to loop through the options
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS

" auto complete brackets // TODO: find better alternative...these interfere when pasting code
"inoremap {      {}<Left>
"inoremap {<CR>  {<CR>}<Esc>O
"inoremap {{     {
"inoremap {}     {}
"inoremap {%     {%%}<Left><Left>
"inoremap {{     {{}}<Left><Left>
"inoremap {}     {}


"##### NAVIGATION ##################################

" swap ' and `. Since ` takes you to the exact column marked and I don't really need that
nnoremap ' `
nnoremap ` '

" make it easier to go to the beginning of the line
nmap H ^
" make it easier to go to the end of the line
nmap L $

"--------- WINDOWS --------------------------------
" shortcuts for moving around windows (instead of using c-w, j...you can simply using c-j) 
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h
" hitting ,, will maximizing current window
map <Leader>, <c-w>_
" hitting ,. will even out all windows
map <Leader>. <c-w>=


" #### TODO: Folds #######
" fold by indentation
"set foldmethod=indent
" set default fold level, 0=all minimized
"set foldlevel=200
" do not show a column to indicate a fold
"set foldcolumn=0


"###### UI ########################################

" Displays the line number and column number on the 'status' line
set ruler
set rulerformat=%10(%l,%c%V%)

" show line numbers on the left
set number

" toggle line numbers (useful for copying code with multiple lines)
map <Leader>r :set invnumber<CR>

" set the terminal title
set title

" Turn syntax highlighting on and specified a colorscheme (.vim/colors/{schemename}.vim)
syntax on
colorscheme enzyme
" If 256 colors are supported
"set t_Co=256
"colorscheme wombat


" briefly jump to the open/close bracket
set showmatch
set matchtime=2

" show trailing spaces, tabs, and end of lines
set listchars=tab:>-,trail:·,eol:$
nmap <silent> <leader>s :set nolist!<CR>

"##### SEARCH ##################################

" highlight search keywords
set hlsearch

" dynamically search term as you type (incremental search)
set incsearch

" These two options, when set together, will make /-style searches case-sensitive only if there is a capital letter in the search expression.
set ignorecase
set smartcase

"##### KEYBOARD SHORTCUTS ##############################

"------ HTML/CSS -----------------------------
" HTML comment/uncomment current line
map <Leader>h I<!--<Esc>A--><Esc>j

map <Leader>H V:s/<!--//g<C-M><Esc>V:s/-->//g<CR><Esc>j

" CSS comment/uncomment current line
map <Leader>c I/*<Esc>A*/<Esc>j
map <Leader>C V:s/\/\*//g<C-M><Esc>V:s/\*\///g<CR><Esc>j

" Append a tag to the end of the current selector 
" (eg: using at on a line like "body #content p {" will take the cursor before the { and go into isnert mode)
map <Leader>ca f{i

" adding zen coding (http://code.google.com/p/zen-coding/ ) support
let g:user_zen_expandabbr_key = '<c-e>'
let g:use_zen_complete_tag = 1
