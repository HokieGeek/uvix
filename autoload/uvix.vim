if exists("g:autoloaded_uvix") || v:version < 700
    finish
endif
let g:autoloaded_uvix = 1

function! uvix#find(...) " {{{
    if a:0 == 1
        let l:loc = "."
        let l:name = a:1
    elseif a:0 == 2
        let l:loc = a:1
        let l:name = a:2
    else
        echohl WarningMsg
        echomsg "Too many arguments. USAGE: Find [LOCATION] [FILE]"
        echohl None
        return
    endif

    if exists("l:name")
        let l:files_list = tempname()
        call system("find ".l:loc." -name '".l:name."' | xargs file | sed 's/:/:1:/' > ".l:files_list)
        let l:ef=&errorformat
        set errorformat=%f:%l:%m
        execute "cfile ".l:files_list
        execute "set errorformat=".l:ef
        cwindow
    endif
endfunction " }}}
function! uvix#chmod(bang, ...) " {{{
    if a:0 > 0
        let l:op = a:bang ? "+x" : a:1
        let l:file = (a:0 > 1) ? bufname(a:2) : expand("%:p")
        call system("chmod ".l:op." ".l:file)
        if a:0 == 1
            edit
        endif
    else
        let l:sed = "'s;.*(\\([0-9]\\{4\\}\\/[-rwx]*\\)).*;\\1;' -e 's/\\([0-9]*\\).\\(.*\\)/\\2 (\\1)/'"
        let l:perms = split(system("stat ".expand("%:p")." | grep 'Access:' | head -1 | sed -e ".l:sed), '\n')[0]
        echomsg l:perms
    endif
endfunction " }}}
function! uvix#remove(...) " {{{
    let l:file = (a:0 > 0) ? bufname(a:1) : expand("%:p")
    let l:file_path = fnamemodify(l:file, ":p")
    call delete(l:file_path)
    if filereadable(l:file_path)
        if confirm("File was not deleted. Still want to delete the buffer?", "y\nN", 2) == 1
            execute "bdelete! ".l:file
        endif
    endif
endfunction " }}}
function! uvix#tail(spawn, file) " {{{
    let l:file = ""
    if exists("b:uvix__last_tail")
        let l:file = b:uvix__last_tail
    endif

    if strlen(a:file) > 0
        let l:file = fnamemodify(a:file, ":p")
        let b:uvix__last_tail = l:file
    endif

    if strlen(l:file) <= 0
        let l:file = expand("%:p")
    endif

    let l:cmd = "tail -F ".l:file
    if a:spawn
        call splitter#LaunchCommandInNewTerminal("", l:cmd)
    else
        call splitter#LaunchCommandHere(l:cmd, 0)
    endif
    " TODO
    " let l:cfg = {'terminal': a:spawn, 'split': !a:spawn, 'vertical':1}
    " function! splitter#LaunchCommand("", cmd, l:cfg)
endfunction " }}}

" vim: set foldmarker={{{,}}} foldmethod=marker formatoptions-=tc:
