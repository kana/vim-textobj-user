" touser - Support for user-defined text objects
" Version: 0.0
" Copyright (C) 2007 kana <http://nicht.s8.xrea.com/>
" License: MIT license (see <http://www.opensource.org/licenses/mit-license>)
" $Id$  "{{{1

if exists('g:loaded_touser')
  finish
endif








" Interfaces  "{{{1

function! TOUser_Move(pattern, flags)
  let i = v:count1
  while 0 < i
    let result = searchpos(a:pattern, a:flags.'W')
    let i = i - 1
  endwhile
  return result
endfunction


" FIXME: growing the current selection like iw/aw, is/as, and others.
" FIXME: countable.
function! TOUser_Select(pattern, flags)
  let ORIG_POS = s:gpos_to_spos(getpos('.'))

  if a:flags =~# 'b'
    let pos_head = searchpos(a:pattern, 'bcW')
    let pos_tail = searchpos(a:pattern, 'eW')
  else
    let pos_tail = searchpos(a:pattern, 'ceW')
    let pos_head = searchpos(a:pattern, 'bW')
  endif

  if s:range_validp(pos_head, pos_tail)
    call cursor(pos_head)
    normal! v
    call cursor(pos_tail)
    return [pos_head, pos_tail]
  else
    " call cursor(ORIG_POS)
    normal! gv
    return 0
  endif
endfunction








" Misc.  "{{{1

" Terms:
"   gpos        [bufnum, lnum, col, off] - a value returned by getpos()
"   spos        [lnum, col] - a value returned by searchpos()
"   pos         same as spos
function! s:gpos_to_spos(gpos)
  return a:gpos[1:2]
endfunction


function! s:range_validp(pos_head, pos_tail)
  let NULL_POS = [0, 0]
  return (a:pos_head != NULL_POS) && (a:pos_tail != NULL_POS)
endfunction








" Etc  "{{{1

let g:loaded_touser = 1








" __END__
" vim: foldmethod=marker
