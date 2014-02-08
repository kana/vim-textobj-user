describe 'move-x-function'
  before
    new

    " Anchored-word is <a> <word> <like> <this>.
    " But <> is not valid, because it doesn't contain a word.

    function! b:move_next()
      while !0
        let [bl, bc] = searchpos('<', 'W')
        let [el, ec] = searchpos('>', 'W')
        if bl == 0 || el == 0
          return 0
        else
          if bl == el && bc + 1 < ec
            return ['v', [0, bl, bc, 0], [0, el, ec, 0]]
          else
            continue
          endif
        endif
      endwhile
    endfunction

    function! b:move_previous()
      while !0
        let [el, ec] = searchpos('>', 'bW')
        let [bl, bc] = searchpos('<', 'bW')
        if bl == 0 || el == 0
          return 0
        else
          if bl == el && bc + 1 < ec
            return ['v', [0, bl, bc, 0], [0, el, ec, 0]]
          else
            continue
          endif
        endif
      endwhile
    endfunction

    call textobj#user#plugin('anchoredword', {
    \   '-': {
    \     'move-n': '<buffer> [n]',
    \     'move-n-function': 'b:move_next',
    \     'move-N': '<buffer> [N]',
    \     'move-N-function': 'b:move_next',
    \     'move-p': '<buffer> [p]',
    \     'move-p-function': 'b:move_previous',
    \     'move-P': '<buffer> [P]',
    \     'move-P-function': 'b:move_previous',
    \   }
    \ })
  end

  after
    close!
  end

  it 'is used to move the cursor to a text object'
    put ='The <quick> brown fox jumps <over> the lazy <dog'
    put ='The> quick <brown> fox <jumps over the> lazy dog'
    1 delete _

    let cases = [
    \   [1,  4, 'n', 1,  5],
    \   [1,  5, 'n', 1, 29],
    \   [1,  6, 'n', 1, 29],
    \   [1, 11, 'n', 1, 29],
    \   [1, 12, 'n', 1, 29],
    \   [1, 28, 'n', 1, 29],
    \   [1, 29, 'n', 2, 12],
    \   [2, 21, 'n', 2, 24],
    \   [2, 23, 'n', 2, 24],
    \   [2, 24, 'n', 2, 24],
    \   [2, 26, 'n', 2, 26],
    \   [1,  4, 'N', 1, 11],
    \   [1,  5, 'N', 1, 34],
    \   [1,  6, 'N', 1, 34],
    \   [1, 11, 'N', 1, 34],
    \   [1, 12, 'N', 1, 34],
    \   [1, 28, 'N', 1, 34],
    \   [1, 29, 'N', 2, 18],
    \   [2, 21, 'N', 2, 39],
    \   [2, 23, 'N', 2, 39],
    \   [2, 24, 'N', 2, 24],
    \   [2, 26, 'N', 2, 26],
    \   [1,  4, 'p', 1,  4],
    \   [1,  5, 'p', 1,  5],
    \   [1,  6, 'p', 1,  6],
    \   [1, 11, 'p', 1, 11],
    \   [1, 12, 'p', 1,  5],
    \   [1, 28, 'p', 1,  5],
    \   [1, 29, 'p', 1,  5],
    \   [2, 21, 'p', 2, 12],
    \   [2, 23, 'p', 2, 12],
    \   [2, 24, 'p', 2, 12],
    \   [2, 26, 'p', 2, 12],
    \   [1,  4, 'P', 1,  4],
    \   [1,  5, 'P', 1,  5],
    \   [1,  6, 'P', 1,  6],
    \   [1, 11, 'P', 1, 11],
    \   [1, 12, 'P', 1, 11],
    \   [1, 28, 'P', 1, 11],
    \   [1, 29, 'P', 1, 11],
    \   [2, 21, 'P', 2, 18],
    \   [2, 23, 'P', 2, 18],
    \   [2, 24, 'P', 2, 18],
    \   [2, 26, 'P', 2, 18],
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
