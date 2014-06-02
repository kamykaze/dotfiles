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

  " enables file type specific plugins (filetype detection will be turned on)
  filetype plugin on

  " Enable mouse support
  set mouse:a


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
  nnoremap <leader><cr><cr> :NERDTreeFind<cr>

  "NeoBundle 'tpope/vim-vinegar'

  " prevent my <leader>d from deleting the Nerdtree buffer, or toggle will cause errors
  autocmd FileType nerdtree nnoremap <buffer> <leader>d :NERDTreeToggle<CR>

  "}}}2

  "## 3d. Finder Integration ##### {{{2

  " reveals the current file in Finder
  NeoBundle 'henrik/vim-reveal-in-finder'
  nmap <leader>f :Reveal<cr>

  "}}}2

  "## 3e. Git Integration ##### {{{2

  " multiple tools for performing git operations on current file/dir
  NeoBundle 'tpope/vim-fugitive'
  map <leader>g :Gstatus<cr>

  " Indicates added/removed/modified lines of code in the gutter column
  NeoBundle 'airblade/vim-gitgutter'

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

  "## 4c. Comments ##### {{{2

  NeoBundle 'scrooloose/nerdcommenter'
  map <c-_> <plug>NERDCommenterToggle       " on my mac, <C-/> gives <c-_>
  vmap <c-?> <plug>NERDCommenterMinimal

  "}}}2

  "## 4d. Utilities ##### {{{2

  NeoBundle 'AndrewRadev/switch.vim'          " toggles yes/no true/false, on/off, etc.
  nnoremap <c-_> :Switch<cr>

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
  let g:SuperTabContextDefaultCompletionType = "<c-n>"

  NeoBundle 'Shougo/neocomplcache.vim'          " shows auto completion options without having to tab
  let g:neocomplcache_enable_at_startup = 1
  let g:neocomplcache_enable_smart_case = 1
  let g:neocomplcache_enable_fuzzy_completion = 1
  let g:neocomplcache_min_syntax_length = 3

  "## 5a. Snippets ##### {{{2
  NeoBundle 'tomtom/tlib_vim'               " used by snipmate
  NeoBundle 'MarcWeber/vim-addon-mw-utils'  " used by snipmate
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
  "let g:user_emmet_togglecomment_key = '<c-_>'
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
  \            'pos.s': 'position:static;',
  \            'pos.a': 'position:absolute;',
  \            'pos.r': 'position:relative;',
  \            'pos.f': 'position:fixed;',
  \            't.a': 'top:auto;',
  \            'r.a': 'right:auto;',
  \            'b.a': 'bottom:auto;',
  \            'l.a': 'left:auto;',
  \            'z.a': 'z-index:auto;',
  \            'fl.n': 'float:none;',
  \            'fl.l': 'float:left;',
  \            'fl.r': 'float:right;',
  \            'cl.n': 'clear:none;',
  \            'cl.l': 'clear:left;',
  \            'cl.r': 'clear:right;',
  \            'cl.b': 'clear:both;',
  \            'd.n': 'display:none;',
  \            'd.b': 'display:block;',
  \            'd.i': 'display:inline;',
  \            'd.ib': 'display:inline-block;',
  \            'd.li': 'display:list-item;',
  \            'd.ri': 'display:run-in;',
  \            'd.cp': 'display:compact;',
  \            'd.tb': 'display:table;',
  \            'd.itb': 'display:inline-table;',
  \            'd.tbcp': 'display:table-caption;',
  \            'd.tbcl': 'display:table-column;',
  \            'd.tbclg': 'display:table-column-group;',
  \            'd.tbhg': 'display:table-header-group;',
  \            'd.tbfg': 'display:table-footer-group;',
  \            'd.tbr': 'display:table-row;',
  \            'd.tbrg': 'display:table-row-group;',
  \            'd.tbc': 'display:table-cell;',
  \            'd.rb': 'display:ruby;',
  \            'd.rbb': 'display:ruby-base;',
  \            'd.rbbg': 'display:ruby-base-group;',
  \            'd.rbt': 'display:ruby-text;',
  \            'd.rbtg': 'display:ruby-text-group;',
  \            'v.v': 'visibility:visible;',
  \            'v.h': 'visibility:hidden;',
  \            'v.c': 'visibility:collapse;',
  \            'ov.v': 'overflow:visible;',
  \            'ov.h': 'overflow:hidden;',
  \            'ov.s': 'overflow:scroll;',
  \            'ov.a': 'overflow:auto;',
  \            'ovx.v': 'overflow-x:visible;',
  \            'ovx.h': 'overflow-x:hidden;',
  \            'ovx.s': 'overflow-x:scroll;',
  \            'ovx.a': 'overflow-x:auto;',
  \            'ovy.v': 'overflow-y:visible;',
  \            'ovy.h': 'overflow-y:hidden;',
  \            'ovy.s': 'overflow-y:scroll;',
  \            'ovy.a': 'overflow-y:auto;',
  \            'ovs.a': 'overflow-style:auto;',
  \            'ovs.s': 'overflow-style:scrollbar;',
  \            'ovs.p': 'overflow-style:panner;',
  \            'ovs.m': 'overflow-style:move;',
  \            'ovs.mq': 'overflow-style:marquee;',
  \            'cp.a': 'clip:auto;',
  \            'cp.r': 'clip:rect(|);',
  \            'bxz.cb': 'box-sizing:content-box;',
  \            'bxz.bb': 'box-sizing:border-box;',
  \            'bxsh.n': 'box-shadow:none;',
  \            'bxsh.w': '-webkit-box-shadow:0 0 0 #000;',
  \            'bxsh.m': '-moz-box-shadow:0 0 0 0 #000;',
  \            'm.a': 'margin:auto;',
  \            'm.0': 'margin:0;',
  \            'm.2': 'margin:0 0;',
  \            'm.3': 'margin:0 0 0;',
  \            'm.4': 'margin:0 0 0 0;',
  \            'mt.a': 'margin-top:auto;',
  \            'mr.a': 'margin-right:auto;',
  \            'mb.a': 'margin-bottom:auto;',
  \            'ml.a': 'margin-left:auto;',
  \            'p.0': 'padding:0;',
  \            'p.2': 'padding:0 0;',
  \            'p.3': 'padding:0 0 0;',
  \            'p.4': 'padding:0 0 0 0;',
  \            'w.a': 'width:auto;',
  \            'h.a': 'height:auto;',
  \            'maw.n': 'max-width:none;',
  \            'mah.n': 'max-height:none;',
  \            'o.n': 'outline:none;',
  \            'oc.i': 'outline-color:invert;',
  \            'bd.n': 'border:none;',
  \            'bdbk.c': 'border-break:close;',
  \            'bdcl.c': 'border-collapse:collapse;',
  \            'bdcl.s': 'border-collapse:separate;',
  \            'bdi.n': 'border-image:none;',
  \            'bdi.w': '-webkit-border-image:url(|) 0 0 0 0 stretch stretch;',
  \            'bdi.m': '-moz-border-image:url(|) 0 0 0 0 stretch stretch;',
  \            'bdti.n': 'border-top-image:none;',
  \            'bdri.n': 'border-right-image:none;',
  \            'bdbi.n': 'border-bottom-image:none;',
  \            'bdli.n': 'border-left-image:none;',
  \            'bdci.n': 'border-corner-image:none;',
  \            'bdci.c': 'border-corner-image:continue;',
  \            'bdtli.n': 'border-top-left-image:none;',
  \            'bdtli.c': 'border-top-left-image:continue;',
  \            'bdtri.n': 'border-top-right-image:none;',
  \            'bdtri.c': 'border-top-right-image:continue;',
  \            'bdbri.n': 'border-bottom-right-image:none;',
  \            'bdbri.c': 'border-bottom-right-image:continue;',
  \            'bdbli.n': 'border-bottom-left-image:none;',
  \            'bdbli.c': 'border-bottom-left-image:continue;',
  \            'bdf.c': 'border-fit:clip;',
  \            'bdf.r': 'border-fit:repeat;',
  \            'bdf.sc': 'border-fit:scale;',
  \            'bdf.st': 'border-fit:stretch;',
  \            'bdf.ow': 'border-fit:overwrite;',
  \            'bdf.of': 'border-fit:overflow;',
  \            'bdf.sp': 'border-fit:space;',
  \            'bdl.a': 'border-length:auto;',
  \            'bds.n': 'border-style:none;',
  \            'bds.h': 'border-style:hidden;',
  \            'bds.dt': 'border-style:dotted;',
  \            'bds.ds': 'border-style:dashed;',
  \            'bds.s': 'border-style:solid;',
  \            'bds.db': 'border-style:double;',
  \            'bds.dtds': 'border-style:dot-dash;',
  \            'bds.dtdtds': 'border-style:dot-dot-dash;',
  \            'bds.w': 'border-style:wave;',
  \            'bds.g': 'border-style:groove;',
  \            'bds.r': 'border-style:ridge;',
  \            'bds.i': 'border-style:inset;',
  \            'bds.o': 'border-style:outset;',
  \            'bdt.n': 'border-top:none;',
  \            'bdts.n': 'border-top-style:none;',
  \            'bdr.n': 'border-right:none;',
  \            'bdrs.n': 'border-right-style:none;',
  \            'bdb.n': 'border-bottom:none;',
  \            'bdbs.n': 'border-bottom-style:none;',
  \            'bdl.n': 'border-left:none;',
  \            'bdls.n': 'border-left-style:none;',
  \            'bdrz.w': '-webkit-border-radius:|;',
  \            'bdrz.m': '-moz-border-radius:|;',
  \            'bg.n': 'background:none;',
  \            'bg.ie': 'filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=''|x.png'');',
  \            'bgi.n': 'background-image:none;',
  \            'bgr.n': 'background-repeat:no-repeat;',
  \            'bgr.x': 'background-repeat:repeat-x;',
  \            'bgr.y': 'background-repeat:repeat-y;',
  \            'bga.f': 'background-attachment:fixed;',
  \            'bga.s': 'background-attachment:scroll;',
  \            'bgbk.bb': 'background-break:bounding-box;',
  \            'bgbk.eb': 'background-break:each-box;',
  \            'bgbk.c': 'background-break:continuous;',
  \            'bgcp.bb': 'background-clip:border-box;',
  \            'bgcp.pb': 'background-clip:padding-box;',
  \            'bgcp.cb': 'background-clip:content-box;',
  \            'bgcp.nc': 'background-clip:no-clip;',
  \            'bgo.pb': 'background-origin:padding-box;',
  \            'bgo.bb': 'background-origin:border-box;',
  \            'bgo.cb': 'background-origin:content-box;',
  \            'bgz.a': 'background-size:auto;',
  \            'bgz.ct': 'background-size:contain;',
  \            'bgz.cv': 'background-size:cover;',
  \            'tbl.a': 'table-layout:auto;',
  \            'tbl.f': 'table-layout:fixed;',
  \            'cps.t': 'caption-side:top;',
  \            'cps.b': 'caption-side:bottom;',
  \            'ec.s': 'empty-cells:show;',
  \            'ec.h': 'empty-cells:hide;',
  \            'lis.n': 'list-style:none;',
  \            'lisp.i': 'list-style-position:inside;',
  \            'lisp.o': 'list-style-position:outside;',
  \            'list.n': 'list-style-type:none;',
  \            'list.d': 'list-style-type:disc;',
  \            'list.c': 'list-style-type:circle;',
  \            'list.s': 'list-style-type:square;',
  \            'list.dc': 'list-style-type:decimal;',
  \            'list.dclz': 'list-style-type:decimal-leading-zero;',
  \            'list.lr': 'list-style-type:lower-roman;',
  \            'list.ur': 'list-style-type:upper-roman;',
  \            'lisi.n': 'list-style-image:none;',
  \            'q.n': 'quotes:none;',
  \            'q.ru': 'quotes:''\00AB'' ''\00BB'' ''\201E'' ''\201C'';',
  \            'q.en': 'quotes:''\201C'' ''\201D'' ''\2018'' ''\2019'';',
  \            'ct.n': 'content:normal;',
  \            'ct.oq': 'content:open-quote;',
  \            'ct.noq': 'content:no-open-quote;',
  \            'ct.cq': 'content:close-quote;',
  \            'ct.ncq': 'content:no-close-quote;',
  \            'ct.a': 'content:attr(|);',
  \            'ct.c': 'content:counter(|);',
  \            'ct.cs': 'content:counters(|);',
  \            'va.sup': 'vertical-align:super;',
  \            'va.t': 'vertical-align:top;',
  \            'va.tt': 'vertical-align:text-top;',
  \            'va.m': 'vertical-align:middle;',
  \            'va.bl': 'vertical-align:baseline;',
  \            'va.b': 'vertical-align:bottom;',
  \            'va.tb': 'vertical-align:text-bottom;',
  \            'va.sub': 'vertical-align:sub;',
  \            'ta.l': 'text-align:left;',
  \            'ta.c': 'text-align:center;',
  \            'ta.r': 'text-align:right;',
  \            'tal.a': 'text-align-last:auto;',
  \            'tal.l': 'text-align-last:left;',
  \            'tal.c': 'text-align-last:center;',
  \            'tal.r': 'text-align-last:right;',
  \            'td.n': 'text-decoration:none;',
  \            'td.u': 'text-decoration:underline;',
  \            'td.o': 'text-decoration:overline;',
  \            'td.l': 'text-decoration:line-through;',
  \            'te.n': 'text-emphasis:none;',
  \            'te.ac': 'text-emphasis:accent;',
  \            'te.dt': 'text-emphasis:dot;',
  \            'te.c': 'text-emphasis:circle;',
  \            'te.ds': 'text-emphasis:disc;',
  \            'te.b': 'text-emphasis:before;',
  \            'te.a': 'text-emphasis:after;',
  \            'th.a': 'text-height:auto;',
  \            'th.f': 'text-height:font-size;',
  \            'th.t': 'text-height:text-size;',
  \            'th.m': 'text-height:max-size;',
  \            'ti.-': 'text-indent:-9999px;',
  \            'tj.a': 'text-justify:auto;',
  \            'tj.iw': 'text-justify:inter-word;',
  \            'tj.ii': 'text-justify:inter-ideograph;',
  \            'tj.ic': 'text-justify:inter-cluster;',
  \            'tj.d': 'text-justify:distribute;',
  \            'tj.k': 'text-justify:kashida;',
  \            'tj.t': 'text-justify:tibetan;',
  \            'to.n': 'text-outline:none;',
  \            'tr.n': 'text-replace:none;',
  \            'tt.n': 'text-transform:none;',
  \            'tt.c': 'text-transform:capitalize;',
  \            'tt.u': 'text-transform:uppercase;',
  \            'tt.l': 'text-transform:lowercase;',
  \            'tw.n': 'text-wrap:normal;',
  \            'tw.no': 'text-wrap:none;',
  \            'tw.u': 'text-wrap:unrestricted;',
  \            'tw.s': 'text-wrap:suppress;',
  \            'tsh.n': 'text-shadow:none;',
  \            'whs.n': 'white-space:normal;',
  \            'whs.p': 'white-space:pre;',
  \            'whs.nw': 'white-space:nowrap;',
  \            'whs.pw': 'white-space:pre-wrap;',
  \            'whs.pl': 'white-space:pre-line;',
  \            'whsc.n': 'white-space-collapse:normal;',
  \            'whsc.k': 'white-space-collapse:keep-all;',
  \            'whsc.l': 'white-space-collapse:loose;',
  \            'whsc.bs': 'white-space-collapse:break-strict;',
  \            'whsc.ba': 'white-space-collapse:break-all;',
  \            'wob.n': 'word-break:normal;',
  \            'wob.k': 'word-break:keep-all;',
  \            'wob.l': 'word-break:loose;',
  \            'wob.bs': 'word-break:break-strict;',
  \            'wob.ba': 'word-break:break-all;',
  \            'wow.nm': 'word-wrap:normal;',
  \            'wow.n': 'word-wrap:none;',
  \            'wow.u': 'word-wrap:unrestricted;',
  \            'wow.s': 'word-wrap:suppress;',
  \            'fw.n': 'font-weight:normal;',
  \            'fw.b': 'font-weight:bold;',
  \            'fw.br': 'font-weight:bolder;',
  \            'fw.lr': 'font-weight:lighter;',
  \            'fs.n': 'font-style:normal;',
  \            'fs.i': 'font-style:italic;',
  \            'fs.o': 'font-style:oblique;',
  \            'fv.n': 'font-variant:normal;',
  \            'fv.sc': 'font-variant:small-caps;',
  \            'fza.n': 'font-size-adjust:none;',
  \            'ff.s': 'font-family:serif;',
  \            'ff.ss': 'font-family:sans-serif;',
  \            'ff.c': 'font-family:cursive;',
  \            'ff.f': 'font-family:fantasy;',
  \            'ff.m': 'font-family:monospace;',
  \            'fef.n': 'font-effect:none;',
  \            'fef.eg': 'font-effect:engrave;',
  \            'fef.eb': 'font-effect:emboss;',
  \            'fef.o': 'font-effect:outline;',
  \            'femp.b': 'font-emphasize-position:before;',
  \            'femp.a': 'font-emphasize-position:after;',
  \            'fems.n': 'font-emphasize-style:none;',
  \            'fems.ac': 'font-emphasize-style:accent;',
  \            'fems.dt': 'font-emphasize-style:dot;',
  \            'fems.c': 'font-emphasize-style:circle;',
  \            'fems.ds': 'font-emphasize-style:disc;',
  \            'fsm.a': 'font-smooth:auto;',
  \            'fsm.n': 'font-smooth:never;',
  \            'fsm.aw': 'font-smooth:always;',
  \            'fst.n': 'font-stretch:normal;',
  \            'fst.uc': 'font-stretch:ultra-condensed;',
  \            'fst.ec': 'font-stretch:extra-condensed;',
  \            'fst.c': 'font-stretch:condensed;',
  \            'fst.sc': 'font-stretch:semi-condensed;',
  \            'fst.se': 'font-stretch:semi-expanded;',
  \            'fst.e': 'font-stretch:expanded;',
  \            'fst.ee': 'font-stretch:extra-expanded;',
  \            'fst.ue': 'font-stretch:ultra-expanded;',
  \            'op.ie': 'filter:progid:DXImageTransform.Microsoft.Alpha(Opacity=100);',
  \            'op.ms': '-ms-filter:''progid:DXImageTransform.Microsoft.Alpha(Opacity=100)'';',
  \            'rz.n': 'resize:none;',
  \            'rz.b': 'resize:both;',
  \            'rz.h': 'resize:horizontal;',
  \            'rz.v': 'resize:vertical;',
  \            'cur.a': 'cursor:auto;',
  \            'cur.d': 'cursor:default;',
  \            'cur.c': 'cursor:crosshair;',
  \            'cur.ha': 'cursor:hand;',
  \            'cur.he': 'cursor:help;',
  \            'cur.m': 'cursor:move;',
  \            'cur.p': 'cursor:pointer;',
  \            'cur.t': 'cursor:text;',
  \            'pgbb.au': 'page-break-before:auto;',
  \            'pgbb.al': 'page-break-before:always;',
  \            'pgbb.l': 'page-break-before:left;',
  \            'pgbb.r': 'page-break-before:right;',
  \            'pgbi.au': 'page-break-inside:auto;',
  \            'pgbi.av': 'page-break-inside:avoid;',
  \            'pgba.au': 'page-break-after:auto;',
  \            'pgba.al': 'page-break-after:always;',
  \            'pgba.l': 'page-break-after:left;',
  \            'pgba.r': 'page-break-after:right;',
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

  " jump like f,w,b,e but in the vertical direction
  NeoBundle 'machakann/vim-columnmove'

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

  " If 256 colors are supported
  set t_Co=256
  let g:hybrid_use_Xresources = 1
  colorscheme hybrid

  "## 7a. Airline ##### {{{2

  " Lightweight statusline based on powerline, but 100% in vim script
  let g:airline_theme='hybrid'
  let g:airline_powerline_fonts = 1         " use nice symbols for powerline
  let g:airline_inactive_collapse=0         " don't collapse airline sections to only filename
  let g:airline#extensions#hunks#enabled = 0      " don't show git gutter
  NeoBundle 'bling/vim-airline'

  "}}}2


  " when closing a bracket, briefly flash the corresponding open bracket
  "set showmatch
  "set matchtime=2

  " color overflow region
  " set colorcolumn=80,120
  " let &colorcolumn=join(range(80,119),",")
  " highlight ColorColumn ctermbg=233 guibg=#181818

  "## 7b. CSS Colors ##### {{{2

  NeoBundle 'runar/vim-css-color', {'rev' : 'scss-support'}         " shows a preview of the CSS color

  "}}}2

  "## 7c. Indentation lines ##### {{{2

  NeoBundle 'Yggdroot/indentLine'
  nnoremap <Leader>i :IndentLinesToggle<cr>

  "}}}2

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


" }}}1


" adding multiple cursors support
" NeoBundle 'terryma/vim-multiple-cursors'
" let g:multi_cursor_use_default_mapping=0
" let g:multi_cursor_start_key='<C-p>'
"let g:multi_cursor_next_key='<C-n>'
"let g:multi_cursor_prev_key='<C-p>'
"let g:multi_cursor_skip_key='<C-x>'
"let g:multi_cursor_quit_key='<Esc>'
"

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
nnoremap <C-A> :Ack<space>
nnoremap <leader>a :Ack <cword><CR>
nnoremap <leader><CR>w :Ack  $VIRTUAL_ENV/src/django-webcube<home><right><right><right><right>
nnoremap <leader><CR>d :Ack  $VIRTUAL_ENV/lib/python2.7/site-packages/django<home><right><right><right><right>
nnoremap <leader><CR>r :Ack  ~/ref/<home><right><right><right><right>
nnoremap <leader><CR>a :Ack <cword><space>




" TODO: sort these
NeoBundle 'clones/vim-l9'
NeoBundle 'xolox/vim-misc'
NeoBundle 'michaeljsmith/vim-indent-object'
NeoBundle 'mattn/webapi-vim'
"NeoBundle 'mattn/livestyle-vim'
NeoBundle 'editorconfig/editorconfig-vim'
NeoBundle 'goldfeld/vim-seek'
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
