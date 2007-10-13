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
" FIXME: In a case of a:pattern matches with one character.
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


function! TOUser_Define(pattern, guideline)
  for function_name in keys(a:guideline)
    let _lhss = a:guideline[function_name]
    if type(_lhss) == type('')
      let lhss = [_lhss]
    else
      let lhss = _lhss
    endif

    for lhs in lhss
      if function_name == 'move-to-next'
        execute 'nnoremap' s:mapargs(lhs, 'Move', a:pattern, '')
      elseif function_name == 'move-to-next-end'
        execute 'nnoremap' s:mapargs(lhs, 'Move', a:pattern, 'e')
      elseif function_name == 'move-to-prev'
        execute 'nnoremap' s:mapargs(lhs, 'Move', a:pattern, 'b')
      elseif function_name == 'move-to-prev-end'
        execute 'nnoremap' s:mapargs(lhs, 'Move', a:pattern, 'be')
      elseif function_name == 'select-next' || function_name == 'select'
        execute 'vnoremap' s:mapargs(lhs, 'Select', a:pattern, '')
        execute 'onoremap' s:mapargs(lhs, 'Select', a:pattern, '')
      elseif function_name == 'select-prev'
        execute 'vnoremap' s:mapargs(lhs, 'Select', a:pattern, 'b')
        execute 'onoremap' s:mapargs(lhs, 'Select', a:pattern, 'b')
      else
        throw 'Unknown function name: ' . string(function_name)
      endif
    endfor
  endfor
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




function! s:mapargs(lhs, func, pattern, flags)
  return printf('<silent> %s  :<C-u>call TOUser_%s(%s, %s)<Return>',
              \ a:lhs, a:func, string(a:pattern), string(a:flags))
endfunction








" Etc  "{{{1

let g:loaded_touser = 1








" __END__
" vim: foldmethod=marker
