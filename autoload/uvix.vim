if exists("g:autoloaded_uvix") || v:version < 700
    finish
endif
let g:autoloaded_uvix = 1

" Helpers {{{
function! uvix#GetExternalGrepCmd() " {{{
    if !exists("g:uvix_external_grep_cmd")
        " Determine which search tool to use
        if executable('ag')
            set grepprg=ag\ --nogroup\ --nocolor\ --column
            set grepformat=%f:%l:%c:%m
            let l:use_external_proc = 1
        elseif executable('ack')
            set grepprg=ack\ --nogroup\ --nocolor\ --column
            set grepformat=%f:%l:%c:%m
            let l:use_external_proc = 1
        elseif executable('grep')
            set grepprg=grep\ -rnIH
            let l:use_external_proc = 1
        else
            let l:use_external_proc = 0
        endif

        let g:uvix_external_grep_cmd = (l:use_external_proc) ? "silent grep" : "noautocmd vimgrep"
    endif
    return g:uvix_external_grep_cmd
endfunction " }}}
" }}}
" Commands {{{
function! uvix#find(case_sensitivity, ...) " {{{
    if a:0 == 1
        let l:loc = "."
        let l:name = a:1
    elseif a:0 == 2
        let l:loc = a:1
        let l:name = a:2
    else
        echohl WarningMsg
        echomsg "Too many arguments. USAGE: Find[!] [LOCATION] [FILE]"
        echohl None
        return
    endif

    if exists("l:name")
        let l:case = a:case_sensitivity ? "" : "i"
        let l:files_list = tempname()
        let l:cmd = "find ".l:loc." -".l:case."name '".l:name."' -print > ".l:files_list
        call system(l:cmd)
        let l:ef=&errorformat
        let g:uvix_find_executed = 1
        setlocal errorformat=%f
        execute "cfile ".l:files_list
        execute "set errorformat=".l:ef
        cwindow
    endif
endfunction " }}}
function! uvix#chmod(default_op, ...) " {{{
    if a:0 > 0 || a:default_op
        let l:op = a:default_op ? "+x" : a:1
        let l:file = (a:0 > 1) ? bufname(a:2) : expand("%:p")
        call system("chmod ".l:op." ".l:file)
        if a:0 == 1
            edit
        endif
    endif
    let l:sed = "'s;.*(\\([0-9]\\{4\\}\\/[-rwx]*\\)).*;\\1;' -e 's/\\([0-9]*\\).\\(.*\\)/\\2 (\\1)/'"
    let l:perms = split(system("stat ".expand("%:p")." | grep 'Access:' | head -1 | sed -e ".l:sed), '\n')[0]
    echomsg l:perms
endfunction " }}}
function! uvix#remove(...) " {{{
    let l:file = (a:0 > 0) ? bufname(a:1) : expand("%:p")
    let l:file_path = fnamemodify(l:file, ":p")
    call delete(l:file_path)
    if filereadable(l:file_path) && confirm("File was not deleted. Still want to delete the buffer?", "y\nN", 2) == 2
        return
    endif
    execute "bdelete! ".l:file
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
    let l:cfg = a:spawn ? 'new_terminal' : 'split_vertical'
    call splitter#LaunchCommand("", l:cmd, l:cfg)
endfunction " }}}
function! uvix#grep(...) " {{{
    let l:args = a:000[:]
    let l:grep_cmd = "vimgrep"
    let l:path = "%"

    " Parse out switches from arguments
    if len(l:args) > 1
        if a:1 == "-a"
            let l:grep_cmd = uvix#GetExternalGrepCmd()
            if l:grep_cmd =~? "vimgrep"
                let l:path = "**"
            elseif l:grep_cmd =~? " grep"
                let l:path = "*"
            else
                let l:path = ""
            endif

            " Determine if case should be ignored
            if &ignorecase
                let l:grep_cmd .= " -i"
            endif

            let l:args = a:000[1:]
        elseif a:1 == "-b"
            let l:grep_cmd = "cexpr [] <bar> bufdo vimgrepadd"

            let l:args = a:000[1:]
        endif
    endif

    " Parse out the rest of the arguments (or use current word as expression)
    if empty(l:args)
        " let l:expression = "\<".expand("<cword>")."\>"
        let l:expression = expand("<cword>")
    else
        let l:expression = l:args[0]
        if len(l:args) > 1
            let l:path = l:args[1]
        endif
    endif

    " If internal grep is being used, then need the correct expression notation
    if l:grep_cmd =~? "vimgrep"
        let l:expression = "/".l:expression."/"
    endif

    " Execute the search and display the qf list if there is more than 1 hit
    silent! execute l:grep_cmd." ".l:expression." ".l:path
    if empty(getqflist())
        echomsg "No matches"
    elseif len(getqflist()) > 1
        cwindow
    endif
endfunction
" }}}
" }}}

" vim: set foldmarker={{{,}}} foldmethod=marker formatoptions-=tc:
