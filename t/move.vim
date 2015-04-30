" Anchored-word is <a> <word> <like> <this>.
" But <> is not valid, because it doesn't contain a word.

call textobj#user#plugin('anchoredwordp', {
\   '-': {
\     'pattern': '<\a\+>',
\     'move-n': '[pn]',
\     'move-N': '[pN]',
\     'move-p': '[pp]',
\     'move-P': '[pP]',
\   }
\ })

let s:pattern = '<\a\+>'

function! s:regionize(bp, ep)
  if a:bp[0] != 0 && a:ep[0] != 0
    return ['v', [0, a:bp[0], a:bp[1], 0], [0, a:ep[0], a:ep[1], 0]]
  else
    return 0
  endif
endfunction

function! Move_n()
  let bp = searchpos(s:pattern, 'W')
  let ep = searchpos(s:pattern, 'ceW')
  return s:regionize(bp, ep)
endfunction

function! Move_N()
  let ep = searchpos(s:pattern, 'eW')
  let bp = searchpos(s:pattern, 'bcW')
  return s:regionize(bp, ep)
endfunction

function! Move_p()
  let bp = searchpos(s:pattern, 'bW')
  let ep = searchpos(s:pattern, 'ceW')
  return s:regionize(bp, ep)
endfunction

function! Move_P()
  let ep = searchpos(s:pattern, 'beW')
  let bp = searchpos(s:pattern, 'bcW')
  return s:regionize(bp, ep)
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

function! s:test_on_normal_mode(type, cases)
  for [il, ic, d, el, ec] in a:cases
    call cursor(il, ic)
    Expect [il, ic] == getpos('.')[1:2]
    execute 'silent! normal' printf('[%s%s]', a:type, d)
    let [_, al, ac, _] = getpos('.')
    Expect [il, ic, d, al, ac] == [il, ic, d, el, ec]
  endfor
endfunction

let s:cases_on_normal_mode = [
\   [1,  4, 'n', 1,  5],
\   [1,  5, 'n', 1, 29],
\   [1,  6, 'n', 1, 29],
\   [1, 10, 'n', 1, 29],
\   [1, 11, 'n', 1, 29],
\   [1, 12, 'n', 1, 29],
\   [2, 11, 'n', 2, 12],
\   [2, 12, 'n', 2, 12],
\   [2, 13, 'n', 2, 13],
\   [2, 17, 'n', 2, 17],
\   [2, 18, 'n', 2, 18],
\   [2, 19, 'n', 2, 19],
\   [1,  4, 'N', 1, 11],
\   [1,  5, 'N', 1, 11],
\   [1,  6, 'N', 1, 11],
\   [1, 10, 'N', 1, 11],
\   [1, 11, 'N', 1, 34],
\   [1, 12, 'N', 1, 34],
\   [2, 11, 'N', 2, 18],
\   [2, 12, 'N', 2, 18],
\   [2, 13, 'N', 2, 18],
\   [2, 17, 'N', 2, 18],
\   [2, 18, 'N', 2, 18],
\   [2, 19, 'N', 2, 19],
\   [1,  4, 'p', 1,  4],
\   [1,  5, 'p', 1,  5],
\   [1,  6, 'p', 1,  5],
\   [1, 10, 'p', 1,  5],
\   [1, 11, 'p', 1,  5],
\   [1, 12, 'p', 1,  5],
\   [2, 11, 'p', 1, 29],
\   [2, 12, 'p', 1, 29],
\   [2, 13, 'p', 2, 12],
\   [2, 17, 'p', 2, 12],
\   [2, 18, 'p', 2, 12],
\   [2, 19, 'p', 2, 12],
\   [1,  4, 'P', 1,  4],
\   [1,  5, 'P', 1,  5],
\   [1,  6, 'P', 1,  6],
\   [1, 10, 'P', 1, 10],
\   [1, 11, 'P', 1, 11],
\   [1, 12, 'P', 1, 11],
\   [2, 11, 'P', 1, 34],
\   [2, 12, 'P', 1, 34],
\   [2, 13, 'P', 1, 34],
\   [2, 17, 'P', 1, 34],
\   [2, 18, 'P', 1, 34],
\   [2, 19, 'P', 2, 18],
\ ]

describe 'textobj#user#plugin'
  before
    new
    put ='The <quick> brown fox jumps <over> the lazy <dog'
    put ='The> quick <brown> fox <jumps over the> lazy dog'
    1 delete _
  end

  after
    close!
  end

  it 'supports "move-*" by "pattern"'
    call s:test_on_normal_mode('p', s:cases_on_normal_mode)
  end

  it 'supports "move-*" by "move-*-function"'
    call s:test_on_normal_mode('f', s:cases_on_normal_mode)
  end
end
