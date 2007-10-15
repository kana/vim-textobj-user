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
    " FIXME: on Operator-pending mode.
    normal! gv
    return 0
  endif
endfunction




" FIXME: NIY, but is this necessary?
" function! TOUser_MovePair(pattern1, pattern2, flags)
" endfunction


function! TOUser_SelectPair(pattern1, pattern2, flags)
  let ORIG_POS = s:gpos_to_spos(getpos('.'))

  " adjust the cursor to the head of a:pattern2 if it's already in the range.
  let pos2c_tail = searchpos(a:pattern2, 'ceW')
  let pos2c_head = searchpos(a:pattern2, 'bcW')
  if !s:range_validp(pos2c_head, pos2c_tail)
    return s:TOUser_SelectPair_Failed()
  endif
  if s:range_containsp(pos2c_head, pos2c_tail, ORIG_POS)
    let more_flags = 'c'
  else
    let more_flags = ''
    call cursor(ORIG_POS)
  endif

  " get the positions of a:pattern1 and a:pattern2.
  let pos2p_head = searchpairpos(a:pattern1, '', a:pattern2, 'W'.more_flags)
  let pos2p_tail = searchpos(a:pattern2, 'ceW')
  if !s:range_validp(pos2p_head, pos2p_tail)
    return s:TOUser_SelectPair_Failed()
  endif
  call cursor(pos2p_head)
  let pos1p_head = searchpairpos(a:pattern1, '', a:pattern2, 'bW')
  let pos1p_tail = searchpos(a:pattern1, 'ceW')
  if !s:range_validp(pos1p_head, pos1p_tail)
    return s:TOUser_SelectPair_Failed()
  endif

  " select the range, then adjust if necessary.
  if a:flags =~# 'i'
    if s:range_no_text_without_edgesp(pos1p_tail, pos2p_head)
      return s:TOUser_SelectPair_Failed()
    endif
    call s:range_select(pos1p_tail, pos2p_head)

    " adjust the range.
    let whichwrap_orig = &whichwrap
    let &whichwrap = '<,>'
    execute "normal! \<Left>o\<Right>"
    let &whichwrap = whichwrap_orig
  else
    call s:range_select(pos1p_head, pos2p_tail)
  endif
  return
endfunction

function! s:TOUser_SelectPair_Failed()
  " FIXME: on Operator-pending mode.
  normal! gv
endfunction




function! TOUser_Define(pattern0, pattern1, pattern2, guideline)
  for function_name in keys(a:guideline)
    let _lhss = a:guideline[function_name]
    if type(_lhss) == type('')
      let lhss = [_lhss]
    else
      let lhss = _lhss
    endif

    for lhs in lhss
      if function_name == 'move-to-next'
        execute 'nnoremap' s:mapargs_single(lhs, 'Move', a:pattern0, '')
      elseif function_name == 'move-to-next-end'
        execute 'nnoremap' s:mapargs_single(lhs, 'Move', a:pattern0, 'e')
      elseif function_name == 'move-to-prev'
        execute 'nnoremap' s:mapargs_single(lhs, 'Move', a:pattern0, 'b')
      elseif function_name == 'move-to-prev-end'
        execute 'nnoremap' s:mapargs_single(lhs, 'Move', a:pattern0, 'be')
      elseif function_name == 'select-next' || function_name == 'select'
        execute 'vnoremap' s:mapargs_single(lhs, 'Select', a:pattern0, '')
        execute 'onoremap' s:mapargs_single(lhs, 'Select', a:pattern0, '')
      elseif function_name == 'select-prev'
        execute 'vnoremap' s:mapargs_single(lhs, 'Select', a:pattern0, 'b')
        execute 'onoremap' s:mapargs_single(lhs, 'Select', a:pattern0, 'b')
      elseif function_name == 'select-pair-all'
        execute 'vnoremap' s:mapargs_pair(lhs, a:pattern1, a:pattern2, 'a')
        execute 'onoremap' s:mapargs_pair(lhs, a:pattern1, a:pattern2, 'a')
      elseif function_name == 'select-pair-inner'
        execute 'vnoremap' s:mapargs_pair(lhs, a:pattern1, a:pattern2, 'i')
        execute 'onoremap' s:mapargs_pair(lhs, a:pattern1, a:pattern2, 'i')
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


function! s:pos_headp(pos)
  return a:pos[1] <= 1
endfunction

function! s:pos_lastp(pos)
  return a:pos[1] == len(getline(a:pos[0]))
endfunction


function! s:pos_le(pos1, pos2)  " less than or equal
  return ((a:pos1[0] < a:pos2[0])
  \       || (a:pos1[0] == a:pos2[0] && a:pos1[1] <= a:pos2[1]))
endfunction




function! s:range_containsp(range_head, range_tail, target_pos)
  return (s:pos_le(a:range_head, a:target_pos)
  \       && s:pos_le(a:target_pos, a:range_tail))
endfunction


function! s:range_no_text_without_edgesp(range_head, range_tail)
  let [hl, hc] = a:range_head
  let [tl, tc] = a:range_tail
  return ((hl == tl && hc - tc == -1)
  \       || (hl - tl == -1
  \           && (s:pos_lastp(a:range_head) && s:pos_headp(a:range_tail))))
endfunction


function! s:range_validp(range_head, range_tail)
  let NULL_POS = [0, 0]
  return (a:range_head != NULL_POS) && (a:range_tail != NULL_POS)
endfunction


function! s:range_select(range_head, range_tail)
  " FIXME: always characterwise, is it okay?
  call cursor(a:range_head)
  normal! v
  call cursor(a:range_tail)
endfunction




function! s:mapargs_single(lhs, func, pattern, flags)
  return printf('<silent> %s  :<C-u>call TOUser_%s(%s, %s)<Return>',
              \ a:lhs, a:func, string(a:pattern), string(a:flags))
endfunction

function! s:mapargs_pair(lhs, pattern1, pattern2, flags)
  return printf('<silent> %s  :<C-u>call TOUser_SelectPair(%s, %s, %s)<CR>',
              \ a:lhs, string(a:pattern1), string(a:pattern2), string(a:flags))
endfunction








" Etc  "{{{1

let g:loaded_touser = 1








" __END__
" vim: foldmethod=marker
