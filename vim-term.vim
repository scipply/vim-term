" Currently idk how to check for closed streams since if the terminal closes,
" the buffer is still open, but trying to write to the terminal is impossible
" and returns an error. So if the terminal exits, it is mandatory to either
" type into the buffer, or :bd Shell\ command
function! s:Cmd(cmd) abort
    let cmd = !empty(a:cmd) ? a:cmd : input('Shell command: ')
    if empty(cmd)
        return
    endif

    let buf_name = 'Shell command'
    let s:bufnr = bufnr(buf_name)
    if s:bufnr == -1
        belowright split
        terminal bash
        call chansend(b:terminal_job_id, 'clear' . "\n")
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

        call chansend(b:terminal_job_id, 'clear' . "\n")
    endif

    " let term_cmd = escape('start=$(date +%s%3N);' . cmd . '; end=$(date +%s%3N); dt=$((end - start)); printf "Command took %d.%03d s\n" $((dt/1000)) $((dt%1000))', '%#')
    let term_cmd = escape('time (' . cmd . ')', '%#')
    call chansend(b:terminal_job_id, term_cmd . "\n")
endfunction

command! -nargs=? Cmd call s:Cmd(<q-args>)
