" Currently idk how to check for closed streams since if the terminal closes,
" the buffer is still open, but trying to write to the terminal is impossible
" and returns an error. So if the terminal exits, it is mandatory to either
" type into the buffer, or :bd Shell\ command

let s:terminal_shell = 'bash'
let s:buf_name = 'Shell Command'
let s:term_cmd = 'time'
let s:input_text = 'Shell command: '

let s:last_cmd = ''

function! s:CustomTerminal() abort
    let sh = &shell
    let &shell = s:terminal_shell
    terminal
    let &shell = sh
endfunction

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

" Issue: when the terminal buffer text becomes longer than the height,
" the clear command will not clear the scrollback buffer and text will
" come from the top of the screen instead of the top of the buffer

function! s:Cmd(cmd) abort
    let cmd = !empty(a:cmd) ? a:cmd : input(s:input_text, '', 'customlist,_FileCompletion')
    if empty(cmd)
        if empty(s:last_cmd)
            return
        else
            let cmd = s:last_cmd
        endif
    endif

    let s:last_cmd = cmd

    let s:bufnr = bufnr(s:buf_name)
    if s:bufnr == -1
        belowright split
        call s:CustomTerminal()
        call chansend(b:terminal_job_id, "clear\e[3J" . "\n")
        execute 'file ' . s:buf_name
        let s:bufnr = bufnr(s:buf_name)
    else
        let s:winnr = winnr()
        let s:bufwinnr = bufwinnr(s:bufnr)
        if s:bufwinnr == -1
            belowright split
            execute 'buffer ' . s:buf_name
        elseif s:bufwinnr != s:winnr
            execute s:bufwinnr . 'wincmd w'
        endif

        call chansend(b:terminal_job_id, "clear\e[3J" . "\n")
    endif

    let term_cmd = escape(s:term_cmd . '(' . cmd . ')', '%#')
    call chansend(b:terminal_job_id, term_cmd . "\n")
    normal! G
endfunction

" Because vim does not allow changing the buffer number or replacing the
" current buffer with a terminal buffer, every time a command is sent
" with this function, the new terminal will use the last used buffer
" number + 2 (because it does enew to keep the window/split properties
" and then deletes the old terminal buffer)
function! s:CmdReplace(cmd) abort
    let cmd = !empty(a:cmd) ? a:cmd : input(s:input_text, '', 'customlist,_FileCompletion')
    if empty(cmd)
        if empty(s:last_cmd)
            return
        else
            let cmd = s:last_cmd
        endif
    endif

    let s:last_cmd = cmd

    let s:bufnr = bufnr(s:buf_name)
    if s:bufnr != -1
        let s:winnr = winnr()
        let s:bufwinnr = bufwinnr(s:bufnr)
        if s:bufwinnr == -1
            belowright split
        elseif s:bufwinnr != s:winnr
            execute s:bufwinnr . 'wincmd w'
        endif
        enew
        execute "bdelete! " . fnameescape(s:buf_name)
    else
        belowright split
    endif

    call s:CustomTerminal()
    execute 'file ' . s:buf_name
    call chansend(b:terminal_job_id, "clear\e[3J" . "\n")

    let term_cmd = escape(s:term_cmd . ' (' . cmd . ')', '%#')
    call chansend(b:terminal_job_id, term_cmd . "\n")
    normal! G
endfunction

command! -nargs=? Cmd call s:Cmd(<q-args>)
command! -nargs=? CmdReplace call s:CmdReplace(<q-args>)
