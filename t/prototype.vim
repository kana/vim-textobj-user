onoremap ix :<C-u>call <SID>target_x()<CR>

function! s:target_x()
  normal! viW
endfunction

describe 'prototype'
  before
    new
    put =[
    \   'if (foo) {',
    \   '  bar()',
    \   '  if (baz()) {',
    \   '    qux()',
    \   '  }',
    \   '}',
    \ ]
    1 delete _
    let @0 = '*nothing changed*'
  end

  after
    close!
  end

  it 'targets a WORD'
    normal! 3G7|
    normal yix
    Expect @0 ==# '(baz())'
  end

  it 'is repeatable'
    normal! 3G7|
    normal dix
    Expect @" ==# '(baz())'
    normal! 4G7|
    normal! .
    Expect @" ==# 'qux()'
  end

  it 'keeps the state of the last Visual mode'
    execute 'normal!' "2GV\<Esc>"
    Expect visualmode() ==# 'V'
    Expect [line("'<"), col("'<")] == [2, 1]
    Expect [line("'>"), col("'>")] == [2, 8]

    normal! 3G7|
    normal yix
    Expect visualmode() ==# 'V'
    Expect [line("'<"), col("'<")] == [2, 1]
    Expect [line("'>"), col("'>")] == [2, 8]
  end
end
