onoremap ix :<C-u>call <SID>target_x()<CR>

function! s:target_x()
  normal! viW
endfunction

" TODO: Might be simplified with <expr>.
onoremap ix <Esc>:<C-u>call <SID>stash()<CR>g@l

" TODO: Support {custom-op}{custom-obj}.
function! s:stash()
  let s:memo = [v:operator, 'TargetX']
  set operatorfunc=OperatorX
endfunction

" TODO: Avoid using v.
function! TargetX()
  normal! viW
endfunction

function! OperatorX(type)
  let [op, function_to_target] = s:memo
  call {function_to_target}()
  execute 'normal!' op
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
