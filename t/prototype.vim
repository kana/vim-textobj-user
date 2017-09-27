onoremap ix :<C-u>call <SID>target_x()<CR>

function! s:target_x()
  normal! viW
endfunction

onoremap ix <Esc>:<C-u>call <SID>stash('TargetX')<CR>g@l

" TODO: Support {custom-op}{custom-obj}.
function! s:stash(target)
  let s:memo = [v:operator, a:target]
  set operatorfunc=OperatorX
endfunction

function! TargetX()
  " Using v here breaks gv.
  call search('\S\+', 'ceW')
  let e = getpos('.')
  call search('\S\+', 'bcW')
  let b = getpos('.')
  return ['v', b, e]
endfunction

" TODO: Support characterwise and exclusive object, though there is no way to
" specify exclusive or inclusive at the moment.
function! OperatorX(type)
  let [op, function_to_target] = s:memo
  let [v, b, e] = {function_to_target}()
  call setpos('.', b)
  execute printf("normal! %s%s:call setpos('.', %s)\<CR>", op, v, string(e))
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

  it 'supports a custom operator'
    set operatorfunc=Foo
    function! Foo(type)
      let v = a:type ==# 'char' ? 'v' : a:type ==# 'line' ? 'V' : "\<C-v>"
      execute printf('normal! `[g?%s`]', v)
    endfunction

    normal! 3G7|
    normal g@ix
    Expect getline('.') ==# "  if (onm()) {"
    normal! 4G7|
    normal! .
    Expect getline('.') ==# "    dhk()"
    normal! .
    Expect getline('.') ==# "    qux()"
  end
end
