" vorg.vim - Vim ORG mode. Your stuff in plain text.
" Maintainer:   Ithai Levi <http://github.org/L3V3L9/>
" Version:      0.3
" GetLatestVimScripts: 2842 1 :AutoInstall: vorg.vim

" Syntax Definition
if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

syn match vorgDeadline        "[<>^]\ \d*[/-]\d*[/-]\d*" contained
syn match vorgTag             "<.*>" contained
syn match vorgLink            "\%(http://\|www\.\)[^ ,;\t]*" contained

syn match vorgLogDate         "[~|]\ \d*[/-]\d*[/-]\d*[ ]@[ ]\d*:\d*" contained
syn match vorgPrefixLogDate   "\ *\d*[/-]\d*[/-]\d*[ ]@[ ]\d*:\d*\ [~|]" contained

syn match vorgDoneText        ".*" contained
syn match vorgTaskText        ".*" contained contains=vorgTag,vorgDeadline,vorgLink,vorgLogDate,vorgPrefixLogDate
syn match vorgTask            "\[[ ]\]" contained nextgroup=vorgTaskText
syn match vorgTaskDone        "\[[xX]\]" contained nextgroup=vorgDoneText

syn match vorgFreeText        ".*" contains=vorgDeadline,vorgTag,vorgLink,vorgTask,vorgTaskDone,vorgTitle,vorgLogDate,vorgPrefixLogDate
syn match vorgListItem        "\t*[-*].*" contains=vorgDeadline,vorgTag,vorgLink,vorgTask,vorgTaskDone,vorgTitle,vorgLogDate,vorgPrefixLogDate
syn match vorgComment         "// .*"

hi def link vorgComment        Comment
hi def link vorgTag            Comment
hi def link vorgTaskText       String
hi def link vorgDoneText       Comment
hi def link vorgListItem       Function
hi def link vorgTask           Special
hi def link vorgTaskDone       Special
hi def link vorgDeadline       Todo
hi def link vorgLogDate        Constant
hi def link vorgPrefixLogDate  Constant
hi def link vorgLink           Constant

" Fold based on the Vorg specification
function! VorgFoldText()
    let foldlines = getline(v:foldstart, v:foldend)
    let text = repeat(' ', indent(v:foldstart)) . substitute(foldlines[0] ,"[ \t]*[-\*]" ,"+" ,"")
    let total_boxes = 0
    let total_checked = 0
    for line in foldlines
        if match(line, "\\[ \\]") > -1
            let total_boxes += 1
        elseif match(line, "\\[x\\]") > -1
            let total_boxes += 1
            let total_checked += 1
        endif
    endfor
    if total_boxes > 0
        let text .= " [ " . total_checked . " / " . total_boxes . " ]"
    endif
    return text . ' '
endfunction

function! VorgFoldExpr(lnum)
    " an empty line - same level
    if match(getline(a:lnum), "^\s*$") > -1
        return '='
    endif

    let current_fold_level = foldlevel(a:lnum - 1)
    let this_line_indent = indent(a:lnum)
    let next_line_indent = indent(nextnonblank(a:lnum + 1))
    let prev_line_indent = indent(prevnonblank(a:lnum - 1))
    " get the current fold level
    if current_fold_level == -1
        if prev_line_indent <= this_line_indent
            let current_fold_level = this_line_indent
        else
            let current_fold_level = prev_line_indent
        endif
        let current_fold_level = current_fold_level / &sw
    endif

    let new_fold_level = this_line_indent / &sw
    if next_line_indent > this_line_indent
        " next line is a fold under the current one
        let new_fold_level += 1
        if new_fold_level <= current_fold_level
            " end fold if another one starts with the same level
            return ">" . new_fold_level
        endif
        let current_fold_level = new_fold_level
    elseif new_fold_level <= current_fold_level
        " ignore unexpected double indents
        let current_fold_level = new_fold_level
    endif

    return current_fold_level
endfunction

setlocal foldmethod=expr
setlocal foldexpr=VorgFoldExpr(v:lnum)
setlocal foldtext=VorgFoldText()

let b:current_syntax = "vorg"
