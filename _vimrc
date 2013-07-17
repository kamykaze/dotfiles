"----------- INITIALIZATION: This needs to be at the top of .vimrc ------------------
" pathogen allows you to manage your plugins and runtime files in their own private directories
" http://www.vim.org/scripts/script.php?script_id=2332
"
" Adding a module is as simple as unzipping the module inside .vim/bundle/[module_name]
" or if you use git
"
" git submodule add http://github.com/user/module_name.git bundle/[module_name]

filetype off
call pathogen#infect()
call pathogen#helptags()

" load barebones vim settings (the one I curl onto a server I don't have my own user profile)
so ~/.vimrc_bare

"-- History --

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
" make sure we use audible bell since we're using powerline
set novisualbell


"##### FILE MANAGEMENT ###############################

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

" map 'Oo' to return to a newline above your current position 
" (useful when you want to close brackets and still continue editing)
inoremap Oo <ESC>O

" remap Ctrl+A and Ctrl+X to +/- for easy increment/decrement of numbers
nnoremap + <c-a>
nnoremap - <c-x>

" creates a line separator  line below the current line
" use any character key after calling this to pick which char to fill the line
" eg: using <leader>1= will create a line like 
" =============
nnoremap <leader>1 yypVr

" convenient copy & paste to clipboard (Mac only)
if has("unix")
  let s:uname = system("uname")
  if s:uname == "Darwin\n"
    vmap <C-x> :!pbcopy<CR>
    vmap <C-c> :w !pbcopy<CR><CR>
    imap <C-v><C-v> <Esc>:r !pbpaste<CR>
  endif
endif

" toggle between UPPER, lower, and Title case
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

"----- AUTO COMPLETION ----------------------------
" map <tab> to either insert a tab, or use <C-N> depending on where the cursor is
function! CleverTab()
    if strpart( getline('.'), 0, col('.')-1 ) =~ '^\s*$' 
        return "\<Tab>"
    elseif strpart( getline('.'), col('.')-2, 1 ) =~ '\s$'
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
autocmd FileType javascript,html,htmldjango,css,scss,less set tabstop=2
autocmd FileType javascript,html,htmldjango,css,scss,less set softtabstop=2
autocmd FileType javascript,html,htmldjango,css,scss,less set shiftwidth=2

autocmd FileType scss imap <buffer> { {<CR>}<Esc>ko<tab>


"----- FILE HANDLING -------------------------------
nnoremap <leader><tab> :NERDTree<CR>
" searches files within current working directory (use <CR> to open in current window, or <C-J> to open in a new window)
nnoremap <silent> ss :FufCoverageFile<CR> 
" searches files that are currently open (use <CR> to load the file in the current window, or <C-J> to jump to the window where the file is open)
nnoremap <silent> sb :FufBuffer<CR>
" Disabled modes we are not using (no reason to use extra memory and slow things down)
let g:fuf_modesDisable = [ 'dir', 'mrufile', 'mrucmd', 'bookmarkfile', 'bookmarkdir', 'tag', 'buffertag', 'taggedfile', 'jumplist', 'changelist', 'line', 'help', 'given', 'givendir', 'givencmd', 'callback', 'callbackitem', ]
" Set <CR> to open in a split window (instead of current window)
let g:fuf_keyOpenSplit = '<CR>'

"##### NAVIGATION ##################################

" remap easymotion leader key to avoid conflict with my custom binding <Leader>,
let g:EasyMotion_leader_key = '<space>'

"--------- WINDOWS --------------------------------
" set minimum window height to 0 instead of 1
set wmh=0


" #### TODO: Folds #######
" fold by indentation
"set foldmethod=indent
" set default fold level, 0=all minimized
"set foldlevel=200
" do not show a column to indicate a fold
"set foldcolumn=0


"###### UI ########################################

" Do not Show the current mode (Normal/Visual/etc.) (already using powerline)
set noshowmode

" toggle line numbers (useful for copying code with multiple lines)
" TODO: use one mapping to rotate between 3 states (relative numbers, abs numbers, and no numbers)
"map <Leader>r :set invnumber<CR>
"let g:NumberToggleTrigger="<Leader>r"

" If 256 colors are supported
set t_Co=256
"colorscheme default
"colorscheme enzyme
"colorscheme wombat
"colorscheme wombat256mod
"colorscheme jellybeans
let g:hybrid_use_Xresources = 1
colorscheme hybrid

" when closing a bracket, briefly flash the corresponding open bracket
"set showmatch
"set matchtime=2

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
let g:Powerline_symbols = 'fancy'

"##### KEYBOARD SHORTCUTS ##############################

"------ VIM ----------------------------------

" Quickly edit/reload the vimrc file
nmap <silent> <leader>ev :tabe $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>


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

" adding multiple cursors support
let g:multi_cursor_use_default_mapping=0
let g:multi_cursor_start_key='<C-p>'
"let g:multi_cursor_next_key='<C-n>'
"let g:multi_cursor_prev_key='<C-p>'
"let g:multi_cursor_skip_key='<C-x>'
"let g:multi_cursor_quit_key='<Esc>'
