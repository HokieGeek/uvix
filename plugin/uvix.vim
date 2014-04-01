if exists("g:loaded_uvix") || v:version < 700
    finish
endif
let g:loaded_uvix = 1

" Will allow me to sudo a file that is open without write permissions
cnoremap w!! %!sudo tee > /dev/null %

command! -bar -bang -complete=file -nargs=+ Find call uvix#find(<bang>0, <f-args>)
command! -bar -bang -complete=buffer -nargs=* Chmod call uvix#chmod(<bang>0, <f-args>)
command! -bar -complete=buffer -nargs=? Rm call uvix#remove(<f-args>)
command! -bar -bang -complete=file -nargs=? Tail call uvix#tail(<bang>0, <q-args>)
command! -nargs=* Grep call uvix#grep(<f-args>)

" vim: set foldmarker={{{,}}} foldmethod=marker formatoptions-=tc:
