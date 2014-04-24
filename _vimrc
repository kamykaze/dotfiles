" vim:foldmethod=marker

" This .vimrc file requires a .vimrc_bare file in the user's home
" directory. The .vimrc_bare is a stripped down bare bones vimrc file
" with some essential mappings and configurations (it assumes you're
" on a server with no home directory), but no extra plugins. 

"# 1. Initialization ##### {{{1

" load barebones vim settings (the one I curl onto a server I don't have my own user profile)
source ~/.vimrc_bare

if has('vim_starting')
   set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Setup NeoBundle for plugin management (tells where plugins should be located)
call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
NeoBundleFetch 'Shougo/neobundle.vim'

" }}}1

"# 2. Core ##### {{{1

  filetype plugin on

  "## 2a. History ##### {{{2
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


  " Asynchronous process used by several of Shougo's plugins (Unite)
  NeoBundle 'Shougo/vimproc.vim', {
    \ 'build': {
      \ 'mac': 'make -f make_mac.mak',
      \ 'unix': 'make -f make_unix.mak',
      \ 'cygwin': 'make -f make_cygwin.mak',
      \ 'windows': '"C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\bin\nmake.exe" make_msvc32.mak',
    \ },
  \ }
  " }}}2

  "## 2b. Errors ##### {{{2

  " make sure we use audible bell since we're using powerline
  set novisualbell
  " }}}2

  "## 2c. Backups ##### {{{2

  " Centralize backups, swapfiles and undo history
  set backupdir=~/.vim/backups
  set directory=~/.vim/swaps
  if exists("&undodir")
      set undodir=~/.vim/undo
  endif

  " Change swap backup frequency (reduce from default of 4s and 200 chars)
  set updatetime=10000
  set updatecount=500
  "}}}2

  "## 3d. Vim Utilities ##### {{{2

  " Quickly edit/reload the vimrc file
  nmap <silent> <leader>ev :tabe $MYVIMRC<CR>
  nmap <silent> <leader>sv :so $MYVIMRC<CR>

  "}}}2

" }}}1

"# 3. Projects ##### {{{1

  "## 3a. Buffers ##### {{{2
  " configuration for Quickbuf plugin
  if mapcheck("<leader>b", "N") != ""
    nunmap <leader>b
    let g:qb_hotkey = "<leader>b"
  endif
  NeoBundle 'vim-scripts/QuickBuf'
  "}}}2
    
  "## 3b. Session ##### {{{2
  NeoBundle 'xolox/vim-session'
  " change default session directory to avoid showing up on dotfiles repo
  let g:session_directory='~/.vim_sessions'
  let g:session_autosave = 'yes'
  "}}}2

  "## 3c. File Navigation ##### {{{2

  "NERDTree for  File navigation
  NeoBundle 'scrooloose/nerdtree'
  let NERDTreeIgnore=['.pyc$[[file]]']          " hide certain files
  nnoremap <leader><tab> :NERDTreeToggle<CR>

  "NeoBundle 'tpope/vim-vinegar'

  " prevent my <leader>d from deleting the Nerdtree buffer, or toggle will cause errors
  autocmd FileType nerdtree nnoremap <buffer> <leader>d :NERDTreeToggle<CR>

  "}}}2

  "## 3d. Finder Integration ##### {{{2

  " reveals the current file in Finder
  NeoBundle 'henrik/vim-reveal-in-finder'
  nmap <leader>f :Reveal<cr>

  "}}}2

" }}}1

"# 4. Editing ##### {{{1

  NeoBundle 'tpope/vim-repeat'            "allows certain plugins to repeat the last command using .
  NeoBundle 'tpope/vim-surround'          "adds mappings for adding/changing/deleting surrounding characters like {}, [], '', and even html tags

  "## 4a. Copy/Paste ##### {{{2

  " convenient copy & paste to clipboard (Mac only)
  if has("unix")
    let s:uname = system("uname")
    if s:uname == "Darwin\n"
      vmap <C-x> :!reattach-to-user-namespace pbcopy<CR>
      vmap <C-c> :w !reattach-to-user-namespace pbcopy<CR><CR>
      imap <C-v><C-v> <Esc>:r !reattach-to-user-namespace pbpaste<CR>
    endif
  endif

  " reselect the text that was just pasted so I can perform commands (like indentation) on it (Steve Losh)
  nnoremap <leader>v V`]

  "}}}2

  "## 4b. Brackets ##### {{{2
  " auto close braces, parentheses, etc.
  let delimitMate_expand_cr = 1
  let delimitMate_expand_space = 1
  NeoBundle 'Raimondi/delimitMate'

  "}}}2

" }}}1

"# 5. Filetypes ##### {{{1

  NeoBundle 'JulesWang/css.vim'
  NeoBundle 'cakebaker/scss-syntax.vim'
  NeoBundle 'KohPoll/vim-less'
  NeoBundle 'vim-scripts/django.vim'

  "----- AUTO COMPLETION ----------------------------
  NeoBundle 'ervandew/supertab'
  let g:SuperTabDefaultCompletionType = "context"

  "## 5a. Snippets ##### {{{2
  NeoBundle 'tomtom/tlib_vim'
  NeoBundle 'MarcWeber/vim-addon-mw-utils'
  NeoBundle 'garbas/vim-snipmate'
  NeoBundle 'honza/vim-snippets'
  " adding snippets directories
  let g:snippets_dir = '~/.vim/snippets/,~/.vim/bundle/snipmate/snippets/'
  "}}}2

  " Note: to use these omnicomplete functions, use Ctrl-k, Ctrl-o, then Ctrl-o again to loop through the options
  autocmd BufNewFile,BufRead *.less set filetype=less.css
  autocmd BufNewFile,BufRead *.html set filetype=htmldjango.html
  autocmd BufNewFile,BufRead *.json set filetype=javascript
  autocmd BufNewFile,BufRead *.py set filetype=python.django
  autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType html set omnifunc=htmlcomplete#CompleteTags

  "------ Emmet --------------------------------
  " adding emmet (http://emmet.io) support
  let g:user_emmet_leader_key = '<C-n>'
  let g:user_emmet_expandabbr_key = '<s-tab><s-tab>'
  let g:user_emmet_togglecomment_key = '<c-_>'
  "let g:user_emmet_next_key = '<C-,>'
  "let g:user_emmet_prev_key = '<C-;>'

  let g:use_emmet_complete_tag = 1
  let g:user_emmet_settings = {
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
  NeoBundle 'mattn/emmet-vim'

  "------ HTML/CSS -----------------------------
  " Sort css properties (courtesy of Steve Losh)
  autocmd FileType css nnoremap <leader>S ?{<CR>jV/\v^\s*\}?$<CR>k:sort<CR>:noh<CR>

  " Some people like merging all css definitions in one line. Use this to sPlit them into multiple lines
  autocmd FileType css map <Leader>P :s/\([{;]\)<space>*\([^$]\)/\1\r<space><space><space><space>\2/g<CR>:noh<CR>

" }}}1

"# 6. Navigation ##### {{{1

  "## 6a. Motions ##### {{{2
  NeoBundle 'Lokaltog/vim-easymotion'
  " remap easymotion leader key to avoid conflict with my custom binding <Leader>,
  let g:EasyMotion_leader_key = '<space>'
  nmap <space>w <Plug>(easymotion-bd-w)
  nmap <space>; <Plug>(easymotion-repeat)

  " }}}2

  "## 6b. Folds ##### {{{2
  set foldmethod=marker           " fold by markers
  set foldlevel=2                 " set default fold level, 0=all minimized
  set foldcolumn=2                " do not show a column to indicate a fold
  set foldnestmax=3               " prevent deep folding

  " custom fold text from http://www.gregsexton.org/2011/03/improving-the-text-displayed-in-a-fold/
  " keeps indentation visible and indicates how much content is in the fold as a percentage
  function! CustomFoldText()
      "get first non-blank line
      let fs = v:foldstart
      while getline(fs) =~ '^\s*$' | let fs = nextnonblank(fs + 1)
      endwhile
      if fs > v:foldend
          let line = getline(v:foldstart)
      else
          let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
      endif

      let w = winwidth(0) - &foldcolumn - (&number ? 8 : 0)
      let foldSize = 1 + v:foldend - v:foldstart
      let foldSizeStr = " " . foldSize . " lines "
      let foldLevelStr = repeat("+--", v:foldlevel)
      let lineCount = line("$")
      let foldPercentage = printf("[%.1f", (foldSize*1.0)/lineCount*100) . "%] "
      let expansionString = repeat(".", w - strwidth(foldSizeStr.line.foldLevelStr.foldPercentage))
      return line . expansionString . foldSizeStr . foldPercentage . foldLevelStr
  endfunction
  set foldtext=CustomFoldText()

  " set fold methods automatically for certain filetypes
  autocmd FileType css,scss,javascript setlocal foldmethod=marker foldmarker={,}
  autocmd FileType vim setlocal foldmethod=marker
  autocmd FileType python setlocal foldmethod=indent

  "}}}2

"}}}1

"# 7. User Interface ##### {{{1

  " Do not Show the current mode (Normal/Visual/etc.) (already using powerline)
  set noshowmode

  " If 256 colors are supported
  set t_Co=256
  let g:hybrid_use_Xresources = 1
  colorscheme hybrid

  " Enable mouse support
  set mouse:a

  " when closing a bracket, briefly flash the corresponding open bracket
  "set showmatch
  "set matchtime=2

  " color overflow region
  " set colorcolumn=80,120
  " let &colorcolumn=join(range(80,119),",")
  " highlight ColorColumn ctermbg=233 guibg=#181818


  "----- Rainbow Parentheses --------------------
  " this makes it so parenthesis, brackets, etc. are colored differently depending on their nesting
  NeoBundle 'kien/rainbow_parentheses.vim'
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

" }}}1


"------ GIT -----------------------------
NeoBundle 'tpope/vim-fugitive'
map <leader>g :Gstatus<cr>

" adding multiple cursors support
" NeoBundle 'terryma/vim-multiple-cursors'
" let g:multi_cursor_use_default_mapping=0
" let g:multi_cursor_start_key='<C-p>'
"let g:multi_cursor_next_key='<C-n>'
"let g:multi_cursor_prev_key='<C-p>'
"let g:multi_cursor_skip_key='<C-x>'
"let g:multi_cursor_quit_key='<Esc>'
"  
NeoBundle 'airblade/vim-gitgutter'

"------ Powerline -----------------------
" adding powerline
if system('whoami') != "root\n"
"else
    set runtimepath+=~/dotfiles/utilities/powerline/powerline/bindings/vim
endif

if ! has('gui_running')
    set ttimeoutlen=10
    augroup FastEscape
        autocmd!
        au InsertEnter * set timeoutlen=300
        au InsertLeave * set timeoutlen=750
    augroup END
endif


"noremap <silent> <leader>t  :TlistToggle<CR>
  
  
"##### TOOLS #####
"----- Tmux Integration ---------------------
NeoBundle 'jgdavey/tslime.vim'
vmap <Leader>m <Plug>SendSelectionToTmux
nmap <Leader>m <Plug>NormalModeSendToTmux
nmap <Leader>z <Plug>SetTmuxVars

"---- CtrlP mapping ---------------------------
NeoBundle 'kien/ctrlp.vim'
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/]public\/media$'
    \ }
let g:ctrlp_working_path_mode = 0
let g:ctrlp_follow_symlinks = 1
let g:ctrlp_prompt_mappings = {
  \ 'PrtCurLeft()':         ['<left>', '<c-^>'],
  \ 'AcceptSelection("h")': ['<c-x>', '<c-cr>', '<c-s>', '<c-h>']
  \ }
nnoremap <leader><space>w :CtrlP $VIRTUAL_ENV/src/django-webcube<CR>
nnoremap <leader><space>d :CtrlP $VIRTUAL_ENV/lib/python2.7/site-packages/django<CR>
nnoremap <leader><space>. :CtrlP ..<cr>
nnoremap <leader><space>r :CtrlP ~/ref/
nnoremap <leader>/ :CtrlPLine %<cr>

"---- Ack mapping ---------------------------
NeoBundle 'mileszs/ack.vim'
nnoremap <C-A> :Ack 
nnoremap <leader>a :Ack <cword><CR>
nnoremap <leader><CR>w :Ack  $VIRTUAL_ENV/src/django-webcube<home><right><right><right><right>
nnoremap <leader><CR>d :Ack  $VIRTUAL_ENV/lib/python2.7/site-packages/django<home><right><right><right><right>
nnoremap <leader><CR>r :Ack  ~/ref/<home><right><right><right><right>
nnoremap <leader><CR>a :Ack <cword> 




" TODO: sort these
NeoBundle 'clones/vim-l9'
NeoBundle 'xolox/vim-misc'
NeoBundle 'michaeljsmith/vim-indent-object'
NeoBundle 'mattn/webapi-vim'
"NeoBundle 'mattn/livestyle-vim'
NeoBundle 'editorconfig/editorconfig-vim'
NeoBundle 'goldfeld/vim-seek'
NeoBundle 'Yggdroot/indentLine'
"NeoBundle 'vim-scripts/taglist.vim'
"NeoBundle 'mileszs/ag.vim'
"NeoBundle 'Lokaltog/powerline'

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

" Clean up removed bundles
    ""TODO: find a way to avoid 'Hit Enter' to continue. Only
    "prompt when there's something to clean
"NeoBundleClean 

call neobundle#end()
