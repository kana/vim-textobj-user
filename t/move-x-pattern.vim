" Anchored-word is <a> <word> <like> <this>.
" But <> is not valid, because it doesn't contain a word.

call textobj#user#plugin('anchoredword', {
\   '-': {
\     'pattern': '<\a\+>',
\     'move-n': '[n]',
\     'move-N': '[N]',
\     'move-p': '[p]',
\     'move-P': '[P]',
\   }
\ })

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
    let cases = [
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
    for [il, ic, d, el, ec] in cases
      call cursor(il, ic)
      Expect [il, ic] == getpos('.')[1:2]
      execute 'silent! normal' printf('[%s]', d)
      let [_, al, ac, _] = getpos('.')
      Expect [il, ic, d, al, ac] == [il, ic, d, el, ec]
    endfor
  end
end

