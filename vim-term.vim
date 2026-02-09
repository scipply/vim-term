" Currently idk how to check for closed streams since if the terminal closes,
" the buffer is still open, but trying to write to the terminal is impossible
" and returns an error. So if the terminal exits, it is mandatory to either
" type into the buffer, or :bd Shell\ command
function! _FileCompletion(A, L, P) abort
    let left_args = strpart(a:L, 0, a:P)
    let args = split(left_args, '\v(^|[^\\])\zs ')
    if empty(args) || left_args =~ '\s$'
        call add(args, '')
    endif
    if len(args) < 2
        return []
    endif

    let stack = join(args[:-2], ' ')
    let completions = []
    for i in map(getcompletion(args[-1], 'file'), 'escape(v:val, " ")')
        let string = stack . ' ' . i
        call add(completions, string)
    endfor

    return completions
endfunction

function! s:Cmd(cmd) abort
    let cmd = !empty(a:cmd) ? a:cmd : input('Shell command: ', '', 'customlist,_FileCompletion')
    if empty(cmd)
        return
    endif

    let buf_name = 'Shell Command'
    let s:bufnr = bufnr(buf_name)
    if s:bufnr == -1
        belowright split
        terminal bash
        call chansend(b:terminal_job_id, "clear\e[3J" . "\n")
        execute 'file ' . buf_name
        let s:bufnr = bufnr(buf_name)
    else
        let s:winnr = winnr()
        let s:bufwinnr = bufwinnr(s:bufnr)
        if s:bufwinnr == -1
            belowright split
            execute 'buffer ' . buf_name
        elseif s:bufwinnr != s:winnr
            execute s:bufwinnr . 'wincmd w'
        endif

        call chansend(b:terminal_job_id, "clear\e[3J" . "\n")
    endif

    let term_cmd = escape('time (' . cmd . ')', '%#')
    call chansend(b:terminal_job_id, term_cmd . "\n")
    normal! G
endfunction

command! -nargs=? Cmd call s:Cmd(<q-args>)
