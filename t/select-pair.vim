function! Test(text, locate_command, pattern1, pattern2, cases)
  for case in a:cases
    let [flag, mode, target_range, target_text] = case
    call setline(1, a:text)
    execute 'normal!' 'gg'.a:locate_command
    silent! delmarks []<>
    let @0 = ''

    silent execute 'normal!' printf(
    \   (mode ==# 'v'
    \    ? "v:\<C-u>call textobj#user#select_pair(%s, %s, %s, %s)\<CR>y"
    \    : "y:\<C-u>call textobj#user#select_pair(%s, %s, %s, %s)\<CR>"),
    \   string(a:pattern1),
    \   string(a:pattern2),
    \   string(flag),
    \   string(mode)
    \ )

    Expect [col("'["), col("']")] == target_range
    Expect [col("'<"), col("'>")] == target_range
    Expect @0 ==# target_text
  endfor
endfunction




describe 'textobj#user#select_pair with different patterns'
  before
    new
    let b:test = function('Test')
  end

  after
    quit!
  end

  it 'selects a proper region if the cursor is on pattern1'
    " (a-1) ___PATTERN1___PATTERN2___pattern1___pattern2___
    "          aaaaaaaaiiiaaaaaaaa
    "          ^
    " (a-2) ___PATTERN1___PATTERN2___pattern1___pattern2___
    "          aaaaaaaaiiiaaaaaaaa
    "             ^
    " (a-3) ___PATTERN1___PATTERN2___pattern1___pattern2___
    "          aaaaaaaaiiiaaaaaaaa
    "                 ^
    for locate_command in ['fP', '2fT', 'f1']
      call b:test(
      \   '___PATTERN1___PATTERN2___pattern1___pattern2___',
      \   locate_command,
      \   '\cPATTERN1',
      \   '\cPATTERN2',
      \   [
      \     ['a', 'o', [4, 22], 'PATTERN1___PATTERN2'],
      \     ['a', 'v', [4, 22], 'PATTERN1___PATTERN2'],
      \     ['i', 'o', [12, 14], '___'],
      \     ['i', 'v', [12, 14], '___'],
      \   ]
      \ )
    endfor
  end

  it 'selects a proper region if the cursor is between pattern1 and pattern2'
    " (b-1) ___PATTERN1___PATTERN2___pattern1___pattern2___
    "          aaaaaaaaiiiaaaaaaaa
    "                  ^
    " (b-2) ___PATTERN1___PATTERN2___pattern1___pattern2___
    "          aaaaaaaaiiiaaaaaaaa
    "                   ^
    " (b-3) ___PATTERN1___PATTERN2___pattern1___pattern2___
    "          aaaaaaaaiiiaaaaaaaa
    "                    ^
    for locate_command in ['f11f_', 'f12f_', 'f13f_']
      call b:test(
      \   '___PATTERN1___PATTERN2___pattern1___pattern2___',
      \   locate_command,
      \   '\cPATTERN1',
      \   '\cPATTERN2',
      \   [
      \     ['a', 'o', [4, 22], 'PATTERN1___PATTERN2'],
      \     ['a', 'v', [4, 22], 'PATTERN1___PATTERN2'],
      \     ['i', 'o', [12, 14], '___'],
      \     ['i', 'v', [12, 14], '___'],
      \   ]
      \ )
    endfor
  end

  it 'selects a proper region if the cursor is on pattern2'
    " (c-1) ___PATTERN1___PATTERN2___pattern1___pattern2___
    "          aaaaaaaaiiiaaaaaaaa
    "                     ^
    " (c-2) ___PATTERN1___PATTERN2___pattern1___pattern2___
    "          aaaaaaaaiiiaaaaaaaa
    "                        ^
    " (c-3) ___PATTERN1___PATTERN2___pattern1___pattern2___
    "          aaaaaaaaiiiaaaaaaaa
    "                            ^
    for locate_command in ['2fP', '2fP2fT', '2fPf2']
      call b:test(
      \   '___PATTERN1___PATTERN2___pattern1___pattern2___',
      \   locate_command,
      \   '\cPATTERN1',
      \   '\cPATTERN2',
      \   [
      \     ['a', 'o', [4, 22], 'PATTERN1___PATTERN2'],
      \     ['a', 'v', [4, 22], 'PATTERN1___PATTERN2'],
      \     ['i', 'o', [12, 14], '___'],
      \     ['i', 'v', [12, 14], '___'],
      \   ]
      \ )
    endfor
  end
end




describe 'textobj#user#select_pair with equivalent patterns'
  before
    new
    let b:test = function('Test')
  end

  after
    quit!
  end

  it 'selects a proper region if the cursor is on pattern1'
    " (a-1) ___PATTERN1___PATTERN2___pattern1___pattern2___
    "          aaaaaaaaiiiaaaaaaaa
    "          ^
    " (a-2) ___PATTERN1___PATTERN2___pattern1___pattern2___
    "          aaaaaaaaiiiaaaaaaaa
    "             ^
    " (a-3) ___PATTERN1___PATTERN2___pattern1___pattern2___
    "          aaaaaaaaiiiaaaaaaaa
    "                 ^
    for locate_command in ['fP', '2fT', 'f1']
      call b:test(
      \   '___PATTERN1___PATTERN2___pattern1___pattern2___',
      \   locate_command,
      \   '\cPATTERN\d',
      \   '\cPATTERN\d',
      \   [
      \     ['a', 'o', [4, 22], 'PATTERN1___PATTERN2'],
      \     ['a', 'v', [4, 22], 'PATTERN1___PATTERN2'],
      \     ['i', 'o', [12, 14], '___'],
      \     ['i', 'v', [12, 14], '___'],
      \   ]
      \ )
    endfor
  end

  it 'selects a proper region if the cursor is between pattern1 and pattern2'
    " (b-1) ___PATTERN1___PATTERN2___pattern1___pattern2___
    "          aaaaaaaaiiiaaaaaaaa
    "                  ^
    " (b-2) ___PATTERN1___PATTERN2___pattern1___pattern2___
    "          aaaaaaaaiiiaaaaaaaa
    "                   ^
    " (b-3) ___PATTERN1___PATTERN2___pattern1___pattern2___
    "          aaaaaaaaiiiaaaaaaaa
    "                    ^
    for locate_command in ['f11f_', 'f12f_', 'f13f_']
      call b:test(
      \   '___PATTERN1___PATTERN2___pattern1___pattern2___',
      \   locate_command,
      \   '\cPATTERN\d',
      \   '\cPATTERN\d',
      \   [
      \     ['a', 'o', [4, 22], 'PATTERN1___PATTERN2'],
      \     ['a', 'v', [4, 22], 'PATTERN1___PATTERN2'],
      \     ['i', 'o', [12, 14], '___'],
      \     ['i', 'v', [12, 14], '___'],
      \   ]
      \ )
    endfor
  end

  it 'selects a proper region if the cursor is on pattern2'
    " (c-1) ___PATTERN1___PATTERN2___pattern1___pattern2___
    "          aaaaaaaaiiiaaaaaaaa
    "                     ^
    " (c-2) ___PATTERN1___PATTERN2___pattern1___pattern2___
    "          aaaaaaaaiiiaaaaaaaa
    "                        ^
    " (c-3) ___PATTERN1___PATTERN2___pattern1___pattern2___
    "          aaaaaaaaiiiaaaaaaaa
    "                            ^
    for locate_command in ['2fP', '2fP2fT', '2fPf2']
      call b:test(
      \   '___PATTERN1___PATTERN2___pattern1___pattern2___',
      \   locate_command,
      \   '\cPATTERN\d',
      \   '\cPATTERN\d',
      \   [
      \     ['a', 'o', [4, 22], 'PATTERN1___PATTERN2'],
      \     ['a', 'v', [4, 22], 'PATTERN1___PATTERN2'],
      \     ['i', 'o', [12, 14], '___'],
      \     ['i', 'v', [12, 14], '___'],
      \   ]
      \ )
    endfor
  end
end
