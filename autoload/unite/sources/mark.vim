let s:save_cpo = &cpo
set cpo&vim

if !exists('g:unite_source_mark_showall')
  let g:unite_source_mark_showall = 0
endif

let s:marks = split(
\   "abcdefghijklmnopqrstuvwxyz"
\ , '\zs'
\ )

let s:all_marks = split(
\   "abcdefghijklmnopqrstuvwxyz"
\ . "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
\ . "0123456789.'`^<>[]{}()\""
\ , '\zs'
\ )

let s:source_mark = {
\   'name': 'mark',
\ }

function! s:source_mark.gather_candidates(args, context)
  let l:candidates = []
  let l:marks = g:unite_source_mark_showall == 1 ? s:all_marks : s:marks
  let l:curr_buf_name = bufname('#')
  execute 'buffer #'
  for l:mark in l:marks
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
  execute 'buffer #'
  return l:candidates
endfunction

function! unite#sources#mark#define()
  return s:source_mark
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

