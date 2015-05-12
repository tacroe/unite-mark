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

let s:mark_info_list = []

let s:source_mark = {
\   'name': 'mark',
\   'hooks': {},
\   'action_table': {},
\ }

function! s:source_mark.hooks.on_init(args, context)
  if empty(a:args)
    let s:marks = s:str2list(g:unite_source_mark_marks)
  else
    let s:marks = s:str2list(a:args[0])
  endif
  let s:marks_bufnr = bufnr('%')
  let s:mark_info_list = s:collect_mark_info(s:marks)
endfunction

function! s:source_mark.gather_candidates(args, context)
  return map(copy(s:mark_info_list), '{
        \   "word": v:val.mark . ":" . v:val.buf_name . ":" . v:val.line,
        \   "abbr": printf("%s: %s [%4d] %s",
        \                  v:val.mark, v:val.buf_name, v:val.line, v:val.snippet),
        \   "source": "mark",
        \   "kind": "jump_list",
        \   "action__path": v:val.path,
        \   "action__line": v:val.line,
        \   "action__mark": v:val.mark,
        \   "action__bufnr": v:val.bufnr,
        \ }')
endfunction

let s:source_mark.action_table.delete = {
      \ 'description' : 'delete from mark list',
      \ 'is_invalidate_cache' : 1,
      \ 'is_quit' : 0,
      \ 'is_selectable' : 1,
      \ }
function! s:source_mark.action_table.delete.func(candidates) "{{{
  let unite_bufnr = bufnr('%')
  for candidate in a:candidates
    if candidate.action__mark =~ '\a'
      execute "buffer! " . candidate.action__bufnr
      execute "delmark " . candidate.action__mark
    else
      echoerr "Special marks can't be deleted! :" . candidate.action__mark
    endif
  endfor
  " restore original bufnr so that gathering marks will be based on that buffer
  execute "buffer! " . s:marks_bufnr
  let s:mark_info_list = s:collect_mark_info(s:marks)
  " restore unite buffer
  execute "buffer! " . unite_bufnr
endfunction"}}}

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
    let l:bufnr = bufnr('%')
  else
    let l:buf_name = bufname(l:pos[0])
    let l:path = l:buf_name
    let l:snippet = ''
    let l:bufnr = l:pos[0]
  endif
  echom "mark : " . a:mark . ":" . l:bufnr
  let l:mark_info = {
        \   'mark': a:mark,
        \   'buf_name': l:buf_name,
        \   'bufnr' : l:bufnr,
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
