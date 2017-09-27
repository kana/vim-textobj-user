" The following is a simplified version of custom text objects defined by
" vim-textobj-user <= 0.7.4.
"
"     onoremap ix :<C-u>call <SID>target_x()<CR>
"
"     function! s:target_x()
"       normal! viW
"     endfunction

onoremap ix <Esc>:<C-u>call <SID>stash('TargetX')<CR>g@l

function! s:stash(target)
  let s:memo = [v:operator, a:target, &operatorfunc]
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
  let [op, function_to_target, operatorfunc] = s:memo
  let [v, b, e] = {function_to_target}()
  call setpos('.', b)
  let &operatorfunc = operatorfunc
  execute printf("normal! %s%s:call setpos('.', %s)\<CR>", op, v, string(e))
  set operatorfunc=OperatorX
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

  it 'sets ''[ and ''] appropriately'
    normal! 3G7|
    normal yiW
    Expect @0 ==# '(baz())'
    Expect [line('''['), col('''[')] == [3, 6]
    Expect [line(''']'), col(''']')] == [3, 12]

    " TODO: Investigate - for some reason this doesn't work.
    normal! 4G7|
    normal! yix
    Expect @0 ==# 'qux()'
    Expect [line('''['), col('''[')] == [4, 5]
    Expect [line(''']'), col(''']')] == [4, 9]
  end

  it 'works with operator c'
    normal! 3G7|
    normal cixINKREDIBLE
    Expect getline('.') ==# '  if INKREDIBLE {'
  end
end
