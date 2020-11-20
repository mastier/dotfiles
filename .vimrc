set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
"Plugin 'craigemery/vim-autotag'
Plugin 'kergoth/vim-bitbake'
Plugin 'scrooloose/syntastic'
"Plugin 'davidhalter/jedi-vim'
Plugin 'chr4/nginx.vim'
Plugin 'dense-analysis/ale'
Plugin 'mitsuhiko/jinja2'
Plugin 'mustache/vim-mustache-handlebars'


" All of your Plugins must be added before the following line
call vundle#end()            " required

" Syntax highlighting
if has("syntax")
    syntax on
    set background=dark
    
    " Comments color distract, let's make it grey!
    hi SpecialKey ctermfg=DarkGray
    hi NonText    ctermfg=DarkGray
    hi Comment    ctermfg=DarkGray 
endif


" Various programming aids
if has("autocmd")
    " per-filetype plugin on
    filetype plugin on
    " per-filetype indent on
    filetype indent on
    " jump to last position (TODO: has problems with window split)
    "autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    " per-filetype settings
    autocmd FileType * call SetFileMappings()
endif

let g:ale_lint_on_text_changed = 'always'
let g:ale_fix_on_save = 0
let g:ale_linters = {
\   'python': ['flake8', 'pylint'],
\   'json': ['jsonlint-php'],
\   'sh': ['shellcheck'],
\   'yaml': ['yamllint'],
\   'javascript': ['jslint'],
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\}

fun SetFileMappings()
    if &ft == "python" || &ft == "pyrex"
        imap <F8> #!/usr/bin/env python# -*- coding: utf-8 -*-
	let g:ale_python_pylint_options = '--rcfile ~/.pylintrc'
        set commentstring=" # %s"
        set tabstop=4
        set shiftwidth=4
        set expandtab
        set shiftround
        set softtabstop=4
        set foldmethod=syntax
    endif

    if &ft == "json"
        set tabstop=4
        set shiftwidth=4
        set expandtab
        set shiftround
        set softtabstop=4
        set foldmethod=syntax
    endif
    
    if &ft == "yaml"
        set tabstop=2
        set shiftwidth=2
        set expandtab
        set shiftround
        set softtabstop=2
        set foldmethod=syntax
    endif

    if &ft == "sh"
        imap <F8> #!/usr/bin/env bash# -*- coding: utf-8 -*-

        set tabstop=2
        set shiftwidth=2
        set expandtab
        set shiftround
        set softtabstop=2
    endif

    if &ft == "ruby"
        set tabstop=2
        set shiftwidth=2
        set expandtab
        set shiftround
        set softtabstop=2
    endif

    if &ft == "c" || &ft == "cpp"
        imap <F1> #include <.h>ODODOD
        imap <F2> #define 
        imap <F8> #include <stdio.h>int main(int argc, char *argv[], char *envp[]){return 0;}OAOA
    endif

    if &ft == "php"
        let html_use_css=1
        let PHP_removeCRwhenUnix = 1
        " Not DTD, starting from HTML5
        imap <F8> <!DOCTYPE html>
    endif
    
    if &ft =~ "htm"
        " Not DTD, starting from HTML5
        imap <F8> <!DOCTYPE html>
        let html_use_css=1
        set tabstop=2
        set shiftwidth=2
        set expandtab
        set shiftround
        set softtabstop=2
    endif
    
    if &ft == "javascript"
        set tabstop=4
        set shiftwidth=4
        set expandtab
        set shiftround
        set softtabstop=4
	let g:syntastic_javascript_checkers = ['jslint']
    endif

    if &ft == "tex"
        set tabstop=4
        set shiftwidth=4
        set expandtab
        set shiftround
        set softtabstop=4
        " it basically sucks, explicitly turned off
        let tex_fold_enabled = 0
        let g:syntastic_tex_checkers    = ['lacheck', 'chktex']
        TTarget pdf
    endif

    if &ft == "perl"
        imap <F8> #!/usr/bin/perluse strict;use warnings;use feature qw(say);use Data::Dumper;use Carp;

        let perl_fold = 1

        set matchpairs+=<:>

        " perl-support.vim
        let g:Perl_AuthorName      = 'Bartosz Woronicz'
        let g:Perl_AuthorRef       = ''
        let g:Perl_Email           = 'bartosz@woronicz.com'
        let g:Perl_Company         = ''
    endif

    if &ft == "xml"
        set tabstop=4
        set shiftwidth=4
        set expandtab
        set shiftround
        set softtabstop=4
    endif


endfun

" Desired defaults!
set showcmd
set showmatch
set incsearch
set hlsearch
set nowrap
set ruler
set splitright
set colorcolumn=100


" Exit Vim from Midnight Commander.
map <F3> ZQ
map <F4> ZQ

set modeline
set modelines=5

" Enhanced command-line completion.
set wildmenu

" http://vim.wikia.com/wiki/Highlight_text_beyond_80_columns
"match Todo '\%81v.*'

" It's 2013.
set ttyfast

packloadall
