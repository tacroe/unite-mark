let s:save_cpo = &cpo
set cpo&vim

if !exists('g:unite_source_mark_marks')
  let g:unite_source_mark_marks = "abcdefghijklmnopqrstuvwxyz"

  " or all marks?
  " let g:unite_source_mark_marks =
  " \   "abcdefghijklmnopqrstuvwxyz"
  " \ . "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  " \ . "0123456789.'`^<>[]{}()\""
endif


function! s:str2list(str)
    return split(a:str, '\zs')
endfunction

let s:marks = s:str2list(g:unite_source_mark_marks)

let s:source_mark = {
\   'name': 'mark',
\ }

function! s:source_mark.gather_candidates(args, context)
  let l:candidates = []
  let l:curr_buf_name = bufname('#')
  buffer #
  for l:mark in s:marks
    let l:pos = getpos("'" . l:mark)
    let l:line = l:pos[1]
    if l:line == 0 " mark does not exist
      continue
    endif
    if l:pos[0] == 0
      let l:buf_name = '%'
      let l:path = l:curr_buf_name
      let l:snippet = getline(l:line)
    else
      let l:buf_name = bufname(l:pos[0])
      let l:path = l:buf_name
      let l:snippet = ''
    endif
    let l:candidate = {
    \   'word': l:mark . l:buf_name . l:snippet,
    \   'abbr': printf('%s: %s [%4d] %s',
    \                  l:mark, l:buf_name, l:line, l:snippet),
    \   'source': 'mark',
    \   'kind': 'jump_list',
    \   'action__path': l:path,
    \   'action__line': l:line,
    \ }
    call add(l:candidates, l:candidate)
  endfor
  buffer #
  return l:candidates
endfunction

function! unite#sources#mark#define()
  return s:source_mark
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

