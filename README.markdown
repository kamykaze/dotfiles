This repository stores all my vim customizations. It is targeted towards web developer using html/css/js on a python/django platform.
While not all features will be applicable to you, I have tried to document them as clearly as possible. Feel free to pick only the things that work for you.

## Features
* pathogen (for easy plugin management in vim)
* custom key mappings for faster/easier navigation
    * <C-hjkl> instead of <C-w>hkl for navigating through windows
    * ,, and ,. to maximize or even window sizes
    * ,r to toggle line numbers (relative, absolute, no numbers)
    * ,p to toggle paste mode
    * H and L instead of ^ and $ to go to beginning/end of line
    * <C-k> instead of <C-x> to enter completion submodes inside 'insert' modes
    * Smart <Tab> completion depending on whether you're at the beginning of a line or completing a word
    * <S-Tab> to trigger emmett/zen coding expansion
    * ss and sb to open Fuzzyfinder's Coverage File (search all files within cur dir) and Buffer modes (search currently opened files)
* case-insensitive search (unless there's an uppercase letter in your keywords)
* syntax and color coding
    * django syntax for html templates
    * html
    * javascript
    * css
    * scss/sass
    * less
* [zen coding](http://code.google.com/p/zen-coding/) plugin (Zen Coding is now known as Emmett) for expanding html/css
* [surround](https://github.com/tpope/vim-surround) plugin for quickly changing quotes, brackets, tags, etc.
* [snipmate](https://github.com/msanders/snipmate.vim) plugin for easy code expansion
    * [snipmate for django](https://github.com/robhudson/snipmate_for_django.git) snippets for django expansion
* [repeat](http://www.vim.org/scripts/script.php?script_id=2136) plugin (for using . to repeat a plugin command)
* [fugitive](https://github.com/tpope/vim-fugitive) plugin for Git integration
* [easymotion](http://www.vim.org/scripts/script.php?script_id=3526) plugin for improved navigation
* [fuzzyfinder](http://www.vim.org/scripts/script.php?script_id=1984) plugin and the required [L9](http://www.vim.org/scripts/script.php?script_id=3252) library for finding files using fuzzy match
* [powerline](https://github.com/Lokaltog/vim-powerline) plugin for nicer status line


## Files
### .vim 
directory of file type configurations and plugins

### .vimrc_bare
my bare minimal vim configuration. It provides remapping and other settings without the use of plugins

### .vimrc
my vim configuration

## Instructions
### Creating source files
Any file which matches the shell glob `_*` will be linked into `$HOME` as a symlink with the first `_`  replaced with a `.`

For example:

    _bashrc

becomes

    ${HOME}/.bashrc

### Installing source files
It's as simple as running:

    ./install.sh

From this top-level directory.

## Requirements
* bash
