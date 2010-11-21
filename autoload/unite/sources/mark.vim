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

function! s:source_mark.on_init(args, context)
  if empty(a:args)
    let l:marks = s:marks
  else
    let l:marks = s:str2list(a:args[0])
  endif
  let s:mark_info_list = s:collect_mark_info(l:marks)
endfunction

function! s:source_mark.gather_candidates(args, context)
  return map(s:mark_info_list, '{
        \   "word": v:val.mark . v:val.buf_name . v:val.snippet,
        \   "abbr": printf("%s: %s [%4d] %s",
        \                  v:val.mark, v:val.buf_name, v:val.line, v:val.snippet),
        \   "source": "mark",
        \   "kind": "jump_list",
        \   "action__path": v:val.path,
        \   "action__line": v:val.line,
        \ }')
endfunction

function! s:collect_mark_info(marks)
  let l:curr_buf_name = bufname('%')
  let l:mark_info_list = [] 
  for l:mark in a:marks
    let l:mark_info = s:get_mark_info(l:mark, l:curr_buf_name)
    if !empty(l:mark_info)
      call add(l:mark_info_list, l:mark_info)
    endif
  endfor
  return l:mark_info_list
endfunction

function! s:get_mark_info(mark, curr_buf_name)
  let l:pos = getpos("'" . a:mark)
  let l:line = l:pos[1]
  if l:line == 0 " mark does not exist
    return {}
  endif
  if l:pos[0] == 0
    let l:buf_name = '%'
    let l:path = a:curr_buf_name
    let l:snippet = getline(l:line)
  else
    let l:buf_name = bufname(l:pos[0])
    let l:path = l:buf_name
    let l:snippet = ''
  endif
  let l:mark_info = {
        \   'mark': a:mark,
        \   'buf_name': l:buf_name,
        \   'path': l:path,
        \   'line': l:line,
        \   'snippet': l:snippet,
        \ } 
  return l:mark_info
endfunction

function! unite#sources#mark#define()
  return s:source_mark
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
