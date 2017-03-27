" infect with patogen
execute pathogen#infect()

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

fun SetFileMappings()
    if &ft == "python" || &ft == "pyrex"
        imap <F8> #!/usr/bin/env python# -*- coding: utf-8 -*-

        set commentstring=" # %s"
        set tabstop=4
        set shiftwidth=4
        set expandtab
        set shiftround
        set softtabstop=4
        set foldmethod=syntax
        let g:syntastic_python_flake8_args = "--max-line-length=150"
	let g:syntastic_python_checkers    = ['flake8', 'pylint']
	let g:syntastic_aggregate_errors = 1
        if has("autocmd")
            autocmd BufWritePre *.py :%s/\s\+$//e
            autocmd BufWritePost *.py SyntasticCheck
        endif
    endif

    if &ft == "json"
        set tabstop=4
        set shiftwidth=4
        set expandtab
        set shiftround
        set softtabstop=4
        set foldmethod=syntax
        let g:syntastic_json_checkers=['jsonlint-php']
        if has("autocmd")
            autocmd BufWritePre *.py :%s/\s\+$//e
            autocmd BufWritePost *.py SyntasticCheck
        endif
    endif
    
    if &ft == "yaml"
        set tabstop=2
        set shiftwidth=2
        set expandtab
        set shiftround
        set softtabstop=2
        set foldmethod=syntax
        let g:syntastic_yaml_checkers=['yamllint']
        if has("autocmd")
            autocmd BufWritePre *.py :%s/\s\+$//e
            autocmd BufWritePost *.py SyntasticCheck
    endif

    if &ft == "sh"
        imap <F8> #!/usr/bin/env bash# -*- coding: utf-8 -*-

        set tabstop=2
        set shiftwidth=2
        set expandtab
        set shiftround
        set softtabstop=2
        let g:syntastic_sh_checkers = ['shellcheck']
        if has("autocmd")
            autocmd BufWritePre *.py :%s/\s\+$//e
            autocmd BufWritePost *.py SyntasticCheck
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
        if has("autocmd")
            autocmd BufWritePre *.htm* :%s/\s\+$//e
            autocmd BufWritePost *.htm* SyntasticCheck
        endif
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
        " it basically sucks, explicitly turned off
        set tabstop=4
        set shiftwidth=4
        set expandtab
        set shiftround
        set softtabstop=4
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
