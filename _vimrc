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

" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='10,\"100,:20,n~/.viminfo

" restores cursor position
function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END



"##### ERRORS ########################################

" Hide error sound/visual error notification
"set noerrorbells
set novisualbell


"##### FILE MANAGEMENT ###############################

" Ignore .pyc when tab-completing filenames
set wildignore=*.swp,*.bak,*.pyc

" Centralize backups, swapfiles and undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
    set undodir=~/.vim/undo
endif

" Change swap backup frequency (reduce from default of 4s and 200 chars)
set updatetime=10000
set updatecount=500

"##### EDITING #######################################

" map kj to Esc. You really don't use kj in editing that often, if at all.
inoremap kj <ESC>

" map 'Oo' to return to a newline above your current position 
" (useful when you want to close brackets and still continue editing)
inoremap Oo <ESC>O

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

" creates a separator "=========" line below the current line
nnoremap <leader>1 yypVr=
nnoremap <leader>2 yypVr-

" map 
vmap <C-x> :!pbcopy<CR>
vmap <C-c> :w !pbcopy<CR><CR>
imap <C-v><C-v> <Esc>:r !pbpaste<CR>

" toggle betwee UPPER, lower, and Title case
function! TwiddleCase(str)
  if a:str ==# toupper(a:str)
    let result = tolower(a:str)
  elseif a:str ==# tolower(a:str)
    let result = substitute(a:str,'\(\<\w\+\>\)', '\u\1', 'g')
  else
    let result = toupper(a:str)
  endif
  return result
endfunction
vnoremap ~ ygv"=TwiddleCase(@")<CR>Pgv

"----- SELECTIONS ---------------------------------
" reselect the text that was just pasted so I can perform commands (like indentation) on it (Steve Losh)
nnoremap <leader>v V`]

" make < > shifts keep selection
vnoremap < <gv
vnoremap > >gv

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
autocmd BufNewFile,BufRead *.scss set filetype=scss
autocmd BufNewFile,BufRead *.less set filetype=less
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd BufNewFile,BufRead *.html set filetype=htmldjango
autocmd FileType actionscript set omnifunc=actionscriptcomplete#CompleteAS
autocmd BufNewFile,BufRead *.as set filetype=actionscript
autocmd FileType html,css set tabstop=2
autocmd FileType html,css set softtabstop=2
autocmd FileType html,css set shiftwidth=2

autocmd FileType scss imap <buffer> { {<CR>}<Esc>ko<tab>


"----- FILE HANDLING -------------------------------
" searches files within current working directory (use <CR> to open in current window, or <C-J> to open in a new window)
nnoremap <silent> ss :FufCoverageFile<CR> 
" searches files that are currently open (use <CR> to load the file in the current window, or <C-J> to jump to the window where the file is open)
nnoremap <silent> sb :FufBuffer<CR>
" Disabled modes we are not using (no reason to use extra memory and slow things down)
let g:fuf_modesDisable = [ 'dir', 'mrufile', 'mrucmd', 'bookmarkfile', 'bookmarkdir', 'tag', 'buffertag', 'taggedfile', 'jumplist', 'changelist', 'line', 'help', 'given', 'givendir', 'givencmd', 'callback', 'callbackitem', ]
" Set <CR> to open in a split window (instead of current window)
let g:fuf_keyOpenSplit = '<CR>'

"##### NAVIGATION ##################################

" swap ' and `. Since ` takes you to the exact column marked and I don't really need that
nnoremap ` '

" make it easier to go to the beginning of the line
map H ^
" make it easier to go to the end of the line
map L $


" make <tab> jump you to the matching bracket in normal or visual modes
nnoremap <tab> %
vnoremap <tab> %

" when you have long wrapped lines, j/k will move you to the next line, which is counter intuitive.
" This mapping makes it so they move to the next "row"
nnoremap j gj
nnoremap k gk

" remap easymotion leader key to avoid conflict with my custom binding <Leader>,
let g:EasyMotion_leader_key = '<Leader>'

"--------- WINDOWS --------------------------------
" set minimum window height to 0 instead of 1
set wmh=0

" shortcuts for moving around windows (instead of using c-w, j...you can simply using c-j) 
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h
" hitting ,, will maximizing current window
map <Leader>, <c-w>_<c-w><bar>
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

" Don't show the intro message when starting vim
set shortmess=atI

" Do not Show the current mode (Normal/Visual/etc.) (already using powerline)
set noshowmode

" Displays the line number and column number on the 'status' line
"set ruler
"set rulerformat=%10(%l,%c%V%)

" show line numbers on the left
set number
set numberwidth=5

" toggle line numbers (useful for copying code with multiple lines)
" TODO: use one mapping to rotate between 3 states (relative numbers, abs numbers, and no numbers)
map <Leader>r :set invnumber<CR>
"let g:NumberToggleTrigger="<Leader>r"

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
"colorscheme jellybeans
let g:hybrid_use_Xresources = 1
colorscheme hybrid

" highlight current line
set cursorline

" always show status line (even if only one window)
set laststatus=2

" when closing a bracket, briefly flash the corresponding open bracket
"set showmatch
"set matchtime=2

" show trailing spaces, tabs, and end of lines
set listchars=tab:>-,trail:·,eol:$,nbsp:_
nmap <silent> <leader>s :set nolist!<CR>

" color overflow region
"set colorcolumn=80,120
"let &colorcolumn=join(range(80,119),",")
"highlight ColorColumn ctermbg=233 guibg=#181818


"----- Rainbow Parentheses --------------------
" this makes it so parenthesis, brackets, etc. are colored differently depending on their nesting
let g:rbpt_colorpairs = [
    \ ['brown',       'RoyalBlue3'],
    \ ['Darkblue',    'SeaGreen3'],
    \ ['darkgray',    'DarkOrchid3'],
    \ ['darkgreen',   'firebrick3'],
    \ ['darkcyan',    'RoyalBlue3'],
    \ ['darkred',     'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['brown',       'firebrick3'],
    \ ['gray',        'RoyalBlue3'],
    \ ['black',       'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['Darkblue',    'firebrick3'],
    \ ['darkgreen',   'RoyalBlue3'],
    \ ['darkcyan',    'SeaGreen3'],
    \ ['darkred',     'DarkOrchid3'],
    \ ['red',         'firebrick3'],
    \ ]
let g:rbpt_max = 16
"au VimEnter * RainbowParenthesesToggle
"au Syntax * RainbowParenthesesLoadChevrons
"au Syntax * RainbowParenthesesLoadRound
"au Syntax * RainbowParenthesesLoadSquare
"au Syntax * RainbowParenthesesLoadBraces
inoremap <leader>`` <esc>:RainbowParenthesesToggle<cr>a
nnoremap <leader>`` :RainbowParenthesesToggle<cr>
nnoremap <leader>`r :RainbowParenthesesLoadRound<cr>
nnoremap <leader>`s :RainbowParenthesesLoadSquare<cr>
nnoremap <leader>`b :RainbowParenthesesLoadBraces<cr>
nnoremap <leader>`c :RainbowParenthesesLoadBraces<cr>

let g:Powerline_colorscheme = 'solarized256'

"##### SEARCH ##################################

" highlight search keywords
set hlsearch

" dynamically search term as you type (incremental search)
set incsearch

" These two options, when set together, will make /-style searches case-sensitive only if there is a capital letter in the search expression.
set ignorecase
set smartcase

" Shortcut to clear out the search highlight after you've found what you were looking for
nnoremap <Esc><Esc> :noh<cr>

"##### KEYBOARD SHORTCUTS ##############################

"------ VIM ----------------------------------

" Quickly edit/reload the vimrc file
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

" Get rid of annoying help when you accidentally hit F1 instead of Esc. Use :h for help
inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

" Save you two keystrokes (pressing/releasing Shift) when typing commands
nnoremap ; :
vnoremap ; :
nnoremap <leader>; ;
vnoremap <leader>; ;



"------ HTML/CSS -----------------------------
" HTML comment/uncomment current line
map <Leader>h I<!--<Esc>A--><Esc>j

map <Leader>H V:s/<!--//g<C-M><Esc>V:s/-->//g<CR><Esc>j

" CSS comment/uncomment current line
map <Leader>c I/*<Esc>A*/<Esc>j
map <Leader>C V:s/\/\*//g<C-M><Esc>V:s/\*\///g<CR><Esc>j

" Sort css properties (courtesy of Steve Losh)
nnoremap <leader>S ?{<CR>jV/\v^\s*\}?$<CR>k:sort<CR>:noh<CR>

" Some people like merging all css definitions in one line. Use this to sPlit them into multiple lines
map <Leader>P :s/\([{;]\)<space>*\([^$]\)/\1\r<space><space><space><space>\2/g<CR>:noh<CR>

" Append a tag to the end of the current selector 
" (eg: using at on a line like "body #content p {" will take the cursor before the { and go into isnert mode)
map <Leader>ca f{i

" adding zen coding (http://code.google.com/p/zen-coding/ ) support
let g:user_zen_leader_key = '<C-n>'

" Shortcut summary:
" n  <C-n>A        <Plug>ZenCodingAnchorizeSummary
" n  <C-n>a        <Plug>ZenCodingAnchorizeURL
" n  <C-n>k        <Plug>ZenCodingRemoveTag
" n  <C-n>j        <Plug>ZenCodingSplitJoinTagNormal
" n  <C-n>/        <Plug>ZenCodingToggleComment
" n  <C-n>i        <Plug>ZenCodingImageSize
" n  <C-n>N        <Plug>ZenCodingPrev
" n  <C-n>n        <Plug>ZenCodingNext
" v  <C-n>D        <Plug>ZenCodingBalanceTagOutwardVisual
" n  <C-n>D        <Plug>ZenCodingBalanceTagOutwardNormal
" v  <C-n>d        <Plug>ZenCodingBalanceTagInwardVisual
" n  <C-n>d        <Plug>ZenCodingBalanceTagInwardNormal
" n  <C-n>;        <Plug>ZenCodingExpandWord
" n  <C-n>,        <Plug>ZenCodingExpandNormal
" v  <C-n>,        <Plug>ZenCodingExpandVisual

let g:user_zen_expandabbr_key = '<s-tab>'
let g:user_zen_togglecomment_key = '<c-_>'
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
\    'indentation' : '  ',
\    'html' : {
\        'snippets' : {
\          'dbl' : "{% block %}\n\t${child}|\n{% endblock %}",
\          'comment' : "{% comment %}\n\t${child}|\n{% endcomment %}",
\          'if' : "{% if | %}\n\t${child}|{% endif %}",
\          'else' : "{% else %}|",
\        },
\    },
\    'css' : {
\        'filters': 'html, fc',
\        'indentation' : '  ',
\        'snippets': {
\            'bgp': 'background-position:|;',
\            'c': 'color:|;',
\            'hp': 'height:|px;',
\            'hh': 'height:auto;',
\            'wp': 'width:|px;',
\            'ww': 'width:100%;|',
\        },
\    },
\}

