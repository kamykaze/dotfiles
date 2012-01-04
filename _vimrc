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

" map <tab> to either insert a tab, or use <C-N> depending on where the cursor is
function! CleverTab()
   if strpart( getline('.'), 0, col('.')-1 ) =~ '^\s*$'
      return "\<Tab>"
   else
      return "\<C-N>"
   endif
endfunction
inoremap <Tab> <C-R>=CleverTab()<CR>

" Note: to use these omnicomplete functions, use Ctrl-k, Ctrl-o, then Ctrl-o again to loop through the options
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd BufNewFile,BufRead *.html set filetype=htmldjango


"##### NAVIGATION ##################################

" swap ' and `. Since ` takes you to the exact column marked and I don't really need that
nnoremap ' `
nnoremap ` '

" make it easier to go to the beginning of the line
map H ^
" make it easier to go to the end of the line
map L $


" remap easymotion leader key to avoid conflict with my custom binding <Leader>,
let g:EasyMotion_leader_key = '<Leader><Space>'

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
" If 256 colors are supported
set t_Co=256
"colorscheme default
"colorscheme enzyme
"colorscheme wombat
"colorscheme wombat256mod
colorscheme jellybeans


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
let g:user_zen_leader_key = '<C-L>'

" Shortcut summary:
" n  <C-L>A        <Plug>ZenCodingAnchorizeSummary
" n  <C-L>a        <Plug>ZenCodingAnchorizeURL
" n  <C-L>k        <Plug>ZenCodingRemoveTag
" n  <C-L>j        <Plug>ZenCodingSplitJoinTagNormal
" n  <C-L>/        <Plug>ZenCodingToggleComment
" n  <C-L>i        <Plug>ZenCodingImageSize
" n  <C-L>N        <Plug>ZenCodingPrev
" n  <C-L>n        <Plug>ZenCodingNext
" v  <C-L>D        <Plug>ZenCodingBalanceTagOutwardVisual
" n  <C-L>D        <Plug>ZenCodingBalanceTagOutwardNormal
" v  <C-L>d        <Plug>ZenCodingBalanceTagInwardVisual
" n  <C-L>d        <Plug>ZenCodingBalanceTagInwardNormal
" n  <C-L>;        <Plug>ZenCodingExpandWord
" n  <C-L>,        <Plug>ZenCodingExpandNormal
" v  <C-L>,        <Plug>ZenCodingExpandVisual

let g:user_zen_expandabbr_key = '<s-tab>'
"let g:user_zen_next_key = '<C-,>'
"let g:user_zen_prev_key = '<C-;>'

""" Other zen key binding settings """
"-------------------------------------
" user_zen_expandabbr_key'
" user_zen_expandword_key'
" user_zen_balancetaginward_key'
" user_zen_balancetagoutward_key'
" user_zen_next_key'
" user_zen_prev_key'
" user_zen_imagesize_key'
" user_zen_togglecomment_key'
" user_zen_splitjointag_key'
" user_zen_removetag_key'
" user_zen_anchorizeurl_key'
" user_zen_anchorizesummary_key'

let g:use_zen_complete_tag = 1
let g:user_zen_settings = {
\    'indentation' : '    ',
\    'html' : {
\        'snippets' : {
\          'dbl' : "{% block %}\n\t${child}|\n{% endblock %}",
\          'comment' : "{% comment %}\n\t${child}|\n{% endcomment %}",
\        },
\    },
\    'css' : {
\        'filters': 'fc',
\        'indentation' : '    ',
\        'snippets': {
\            'bgp': 'background-position:|;',
\            'c': 'color:#|;',
\            'fz': 'font-size:|px;',
\            'h': 'height:|px;',
\            'lh': 'line-height:|px;',
\            'mb': 'margin-bottom:|px;',
\            'ml': 'margin-left:|px;',
\            'mt': 'margin-top:|px;',
\            'mr': 'margin-right:|px;',
\            'pb': 'padding-bottom:|px;',
\            'pl': 'padding-left:|px;',
\            'pt': 'padding-top:|px;',
\            'pr': 'padding-right:|px;',
\            's': 'font-size:|px;',
\            'w': 'width:|px;',
\            't': 'top:|px;',
\            'b': 'bottom:|px;',
\            'l': 'left:|px;',
\            'r': 'right:|px;',
\        },
\    },
\}


" when using css zen, css rules get generated in the same line; use this shortcut to separate them into multiple lines
map <Leader>t :s/;\([^$]\)/;\r\t\1/g<C-M>
