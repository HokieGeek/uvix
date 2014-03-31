if exists("g:loaded_uvix") || v:version < 700
    finish
endif
let g:loaded_uvix = 1

command! -bar -bang -complete=file -nargs=+ Find call uvix#find(<bang>0, <f-args>)
command! -bar -bang -complete=buffer -nargs=* Chmod call uvix#chmod(<bang>0, <f-args>)
command! -bar -complete=buffer -nargs=? Rm call uvix#remove(<f-args>)
command! -bar -bang -complete=file -nargs=? Tail call uvix#tail(<bang>1, <q-args>)

" vim: set foldmarker={{{,}}} foldmethod=marker formatoptions-=tc:
