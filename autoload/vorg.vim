function! vorg#toggleCheckbox() range
    let view = winsaveview()
    if a:firstline != a:lastline || vorg#toggleRadio(a:firstline) == 0
        let lines = getline(a:firstline, a:lastline)
        let linenum = a:firstline
        for line in lines
            if match(line, "\\[x\\]") > -1
                call setline(linenum, substitute(line, "\\[x\\]", "[ ]", ""))
            elseif match(line, "\\[ \\]") > -1
                call setline(linenum, substitute(line, "\\[ \\]", "[x]", ""))
            endif

            let linenum += 1
        endfor
    endif
    call winrestview(view)
endfunction

function! vorg#clearRadioBlock(linenum)
    let ind_level = indent(a:linenum)
    for direction in [1, -1]
        let curline = a:linenum + direction
        while 1
            let line = getline(curline)
            if indent(curline) == ind_level && match(line, "([x ])") > -1
                call setline(curline, substitute(line, "(x)", "( )", ""))
            else
                break
            endif
            let curline += direction
        endwhile
    endfor
endfunction

function! vorg#toggleRadio(linenum)
    let line = getline(a:linenum)
    if match(line, "(x)") > -1
        call setline(a:linenum, substitute(line, "(x)", "( )", ""))
        return 1
    elseif match(line, "( )") > -1
        call vorg#clearRadioBlock(a:linenum)
        call setline(a:linenum, substitute(line, "( )", "(x)", ""))
        return 1
    endif

    return 0
endfunction

function! vorg#dateFollowing(nDays)
    let dir  = a:nDays < 0 ? -1 : 1
    let day  = abs(a:nDays) % 7
    let sday = 60 * 60 * 24 * dir
    let time = localtime() + sday
    while strftime('%w', time) != day
        let time += sday
    endwhile
    return strftime('%Y-%m-%d', time)
endfunction

function! s:tmpQuickfix()
    copen
    nnoremap <buffer> o <CR>
    nnoremap <buffer> q :q<CR>
endfunction

function! vorg#gather(pattern)
    if !empty(a:pattern)
        execute "silent! vimgrep /" . a:pattern . "/j " . substitute(expand('%'), " ", "\\\\ ", "g")
        call s:tmpQuickfix()
    endif
endfunction

function! vorg#gatherAll(pattern)
    if !empty(a:pattern)
        execute "silent! vimgrep /" . a:pattern . "/j **/*.vorg"
        call s:tmpQuickfix()
    endif
endfunction
