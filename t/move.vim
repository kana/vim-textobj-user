" Anchored-word is <a> <word> <like> <this>.
" But <> is not valid, because it doesn't contain a word.

" "pattern" "{{{1

call textobj#user#plugin('anchoredwordp', {
\   '-': {
\     'pattern': '<\a\+>',
\     'move-n': '[pn]',
\     'move-N': '[pN]',
\     'move-p': '[pp]',
\     'move-P': '[pP]',
\   }
\ })

" "move-*-function" "{{{1

let s:pattern = '<\a\+>'

function! s:regionize(bp, ep)
  if a:bp[0] != 0 && a:ep[0] != 0
    return ['v', [0, a:bp[0], a:bp[1], 0], [0, a:ep[0], a:ep[1], 0]]
  else
    return 0
  endif
endfunction

function! s:_move(type)
  if a:type ==# 'n'
    let bp = searchpos(s:pattern, 'W')
    let ep = searchpos(s:pattern, 'ceW')
  elseif a:type ==# 'N'
    let ep = searchpos(s:pattern, 'eW')
    let bp = searchpos(s:pattern, 'bcW')
    call cursor(ep)
  elseif a:type ==# 'p'
    let bp = searchpos(s:pattern, 'bW')
    let ep = searchpos(s:pattern, 'ceW')
    call cursor(bp)
  else  " if a:type ==# 'P'
    let ep = searchpos(s:pattern, 'beW')
    let bp = searchpos(s:pattern, 'bcW')
  endif
  return s:regionize(bp, ep)
endfunction

function! s:move(type, count)
  for i in range(a:count)
    silent! unlet r
    let r = s:_move(a:type)
    if r is 0
      break
    endif
    let rr = r
  endfor
  return exists('rr') ? rr : 0
endfunction

function! Move_n()
  return s:move('n', v:count1)
endfunction

function! Move_N()
  return s:move('N', v:count1)
endfunction

function! Move_p()
  return s:move('p', v:count1)
endfunction

function! Move_P()
  return s:move('P', v:count1)
endfunction

call textobj#user#plugin('anchoredwordf', {
\   '-': {
\     'move-n': '[fn]',
\     'move-n-function': 'Move_n',
\     'move-N': '[fN]',
\     'move-N-function': 'Move_N',
\     'move-p': '[fp]',
\     'move-p-function': 'Move_p',
\     'move-P': '[fP]',
\     'move-P-function': 'Move_P',
\   }
\ })

" Test cases "{{{1

function! s:test_on_normal_mode(type, cases)
  for [il, ic, c, d, ebl, ebc, eel, eec] in a:cases
    call cursor(il, ic)
    Expect [il, ic] == getpos('.')[1:2]
    execute 'silent! normal' printf('%s[%s%s]', c ? c : '', a:type, d)
    let [_, al, ac, _] = getpos('.')
    let el = d =~# '[pP]' ? ebl : eel
    let ec = d =~# '[pP]' ? ebc : eec
    Expect [il, ic, c, d, al, ac] == [il, ic, c, d, el, ec]
  endfor
endfunction

function! s:test_on_visual_mode(type, cases)
  for [il, ic, c, d, ebl, ebc, eel, eec] in a:cases
    call cursor(il, ic)
    Expect [il, ic] == getpos('.')[1:2]
    execute 'silent! normal' printf("v%s[%s%s]\<Esc>", c ? c : '', a:type, d)
    let [_, al, ac, _] = getpos('.')
    let el = d =~# '[pP]' ? ebl : eel
    let ec = d =~# '[pP]' ? ebc : eec
    Expect [il, ic, c, d, al, ac] == [il, ic, c, d, el, ec]
  endfor
endfunction

function! s:test_on_operator_pending_mode(type, cases)
  for [il, ic, c, d, ebl, ebc, eel, eec] in a:cases
    call cursor(il, ic)
    Expect [il, ic] == getpos('.')[1:2]
    execute 'silent! normal' printf('y%s[%s%s]', c ? c : '', a:type, d)
    let [_, abl, abc, _] = getpos("'[")
    let [_, ael, aec, _] = getpos("']")
    Expect [il, ic, c, d, abl, abc, ael, aec]
    \   == [il, ic, c, d, ebl, ebc, eel, eec]
  endfor
endfunction

let s:cases = [
\   [1,  4, 0, 'n', 1,  4, 1,  5],
\   [1,  5, 0, 'n', 1,  5, 1, 29],
\   [1,  6, 0, 'n', 1,  6, 1, 29],
\   [1, 10, 0, 'n', 1, 10, 1, 29],
\   [1, 11, 0, 'n', 1, 11, 1, 29],
\   [1, 12, 0, 'n', 1, 12, 1, 29],
\   [2, 11, 0, 'n', 2, 11, 2, 12],
\   [2, 12, 0, 'n', 2, 12, 2, 12],
\   [2, 13, 0, 'n', 2, 13, 2, 13],
\   [2, 17, 0, 'n', 2, 17, 2, 17],
\   [2, 18, 0, 'n', 2, 18, 2, 18],
\   [2, 19, 0, 'n', 2, 19, 2, 19],
\   [1,  1, 1, 'n', 1,  1, 1,  5],
\   [1,  1, 2, 'n', 1,  1, 1, 29],
\   [1,  1, 3, 'n', 1,  1, 2, 12],
\   [1,  1, 4, 'n', 1,  1, 2, 12],
\
\   [1,  4, 0, 'N', 1,  4, 1, 11],
\   [1,  5, 0, 'N', 1,  5, 1, 11],
\   [1,  6, 0, 'N', 1,  6, 1, 11],
\   [1, 10, 0, 'N', 1, 10, 1, 11],
\   [1, 11, 0, 'N', 1, 11, 1, 34],
\   [1, 12, 0, 'N', 1, 12, 1, 34],
\   [2, 11, 0, 'N', 2, 11, 2, 18],
\   [2, 12, 0, 'N', 2, 12, 2, 18],
\   [2, 13, 0, 'N', 2, 13, 2, 18],
\   [2, 17, 0, 'N', 2, 17, 2, 18],
\   [2, 18, 0, 'N', 2, 18, 2, 18],
\   [2, 19, 0, 'N', 2, 19, 2, 19],
\   [1,  1, 1, 'N', 1,  1, 1, 11],
\   [1,  1, 2, 'N', 1,  1, 1, 34],
\   [1,  1, 3, 'N', 1,  1, 2, 18],
\   [1,  1, 4, 'N', 1,  1, 2, 18],
\
\   [1,  4, 0, 'p', 1,  4, 1,  4],
\   [1,  5, 0, 'p', 1,  5, 1,  5],
\   [1,  6, 0, 'p', 1,  5, 1,  6],
\   [1, 10, 0, 'p', 1,  5, 1, 10],
\   [1, 11, 0, 'p', 1,  5, 1, 11],
\   [1, 12, 0, 'p', 1,  5, 1, 12],
\   [2, 11, 0, 'p', 1, 29, 2, 11],
\   [2, 12, 0, 'p', 1, 29, 2, 12],
\   [2, 13, 0, 'p', 2, 12, 2, 13],
\   [2, 17, 0, 'p', 2, 12, 2, 17],
\   [2, 18, 0, 'p', 2, 12, 2, 18],
\   [2, 19, 0, 'p', 2, 12, 2, 19],
\   [2, 48, 1, 'p', 2, 12, 2, 48],
\   [2, 48, 2, 'p', 1, 29, 2, 48],
\   [2, 48, 3, 'p', 1,  5, 2, 48],
\   [2, 48, 4, 'p', 1,  5, 2, 48],
\
\   [1,  4, 0, 'P', 1,  4, 1,  4],
\   [1,  5, 0, 'P', 1,  5, 1,  5],
\   [1,  6, 0, 'P', 1,  6, 1,  6],
\   [1, 10, 0, 'P', 1, 10, 1, 10],
\   [1, 11, 0, 'P', 1, 11, 1, 11],
\   [1, 12, 0, 'P', 1, 11, 1, 12],
\   [2, 11, 0, 'P', 1, 34, 2, 11],
\   [2, 12, 0, 'P', 1, 34, 2, 12],
\   [2, 13, 0, 'P', 1, 34, 2, 13],
\   [2, 17, 0, 'P', 1, 34, 2, 17],
\   [2, 18, 0, 'P', 1, 34, 2, 18],
\   [2, 19, 0, 'P', 2, 18, 2, 19],
\   [2, 48, 1, 'P', 2, 18, 2, 48],
\   [2, 48, 2, 'P', 1, 34, 2, 48],
\   [2, 48, 3, 'P', 1, 11, 2, 48],
\   [2, 48, 4, 'P', 1, 11, 2, 48],
\ ]

" }}}1

describe '"move-*"'
  before
    new
    put ='The <quick> brown fox jumps <over> the lazy <dog'
    put ='The> quick <brown> fox <jumps over the> lazy dog'
    1 delete _
  end

  after
    close!
  end

  context 'defined by "pattern"'
    it 'works in Normal mode'
      call s:test_on_normal_mode('p', s:cases)
    end

    it 'works in Visual mode'
      call s:test_on_visual_mode('p', s:cases)
    end

    it 'works in Operator-pending mode'
      call s:test_on_operator_pending_mode('p', s:cases)
    end
  end

  context 'defined by "move-*-function"'
    it 'works in Normal mode'
      call s:test_on_normal_mode('f', s:cases)
    end

    it 'works in Visual mode'
      call s:test_on_visual_mode('f', s:cases)
    end

    it 'works in Operator-pending mode'
      call s:test_on_operator_pending_mode('f', s:cases)
    end
  end
end

" vim: foldmethod=marker
