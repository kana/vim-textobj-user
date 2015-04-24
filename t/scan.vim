call textobj#user#plugin('number', {
\   'default': {
\     'pattern': '\a\+',
\     'select': 'nd',
\   },
\   'cursor': {
\     'pattern': '\a\+',
\     'select': 'nc',
\     'scan': 'cursor',
\   },
\   'forward': {
\     'pattern': '\a\+',
\     'select': 'nf',
\     'scan': 'forward',
\   },
\ })

function! Select(lnum, col, object)
  call cursor(a:lnum, a:col)
  execute 'normal' 'v'.a:object."\<Esc>"
  return [visualmode(), getpos("'<")[1:2], getpos("'>")[1:2]]
endfunction

describe '"pattern"-based text object'
  before
    new
    0 put =[
    \   '___AAA___',
    \   'BBB___CCC',
    \   '___DDD___',
    \ ]
  end

  after
    close!
  end

  context 'without "scan"'
    it 'is targeted if it is under or following to the cursor'
      Expect Select(1, 1, 'nd') ==# ['v', [1, 4], [1, 6]]
      Expect Select(1, 2, 'nd') ==# ['v', [1, 4], [1, 6]]
      Expect Select(1, 3, 'nd') ==# ['v', [1, 4], [1, 6]]
      Expect Select(1, 4, 'nd') ==# ['v', [1, 4], [1, 6]]
      Expect Select(1, 5, 'nd') ==# ['v', [1, 4], [1, 6]]
      Expect Select(1, 6, 'nd') ==# ['v', [1, 4], [1, 6]]
      Expect Select(1, 7, 'nd') ==# ['v', [2, 1], [2, 3]]
      Expect Select(1, 8, 'nd') ==# ['v', [2, 1], [2, 3]]
      Expect Select(1, 9, 'nd') ==# ['v', [2, 1], [2, 3]]

      Expect Select(2, 1, 'nd') ==# ['v', [2, 1], [2, 3]]
      Expect Select(2, 2, 'nd') ==# ['v', [2, 1], [2, 3]]
      Expect Select(2, 3, 'nd') ==# ['v', [2, 1], [2, 3]]
      Expect Select(2, 4, 'nd') ==# ['v', [2, 7], [2, 9]]
      Expect Select(2, 5, 'nd') ==# ['v', [2, 7], [2, 9]]
      Expect Select(2, 6, 'nd') ==# ['v', [2, 7], [2, 9]]
      Expect Select(2, 7, 'nd') ==# ['v', [2, 7], [2, 9]]
      Expect Select(2, 8, 'nd') ==# ['v', [2, 7], [2, 9]]
      Expect Select(2, 9, 'nd') ==# ['v', [2, 7], [2, 9]]

      Expect Select(3, 1, 'nd') ==# ['v', [3, 4], [3, 6]]
      Expect Select(3, 2, 'nd') ==# ['v', [3, 4], [3, 6]]
      Expect Select(3, 3, 'nd') ==# ['v', [3, 4], [3, 6]]
      Expect Select(3, 4, 'nd') ==# ['v', [3, 4], [3, 6]]
      Expect Select(3, 5, 'nd') ==# ['v', [3, 4], [3, 6]]
      Expect Select(3, 6, 'nd') ==# ['v', [3, 4], [3, 6]]
      Expect Select(3, 7, 'nd') ==# ['v', [3, 7], [3, 7]]
      Expect Select(3, 8, 'nd') ==# ['v', [3, 8], [3, 8]]
      Expect Select(3, 9, 'nd') ==# ['v', [3, 9], [3, 9]]
    end
  end

  context 'with "scan" = "cursor"'
    it 'is targeted if it is under the cursor'
      Expect Select(1, 1, 'nc') ==# ['v', [1, 1], [1, 1]]
      Expect Select(1, 2, 'nc') ==# ['v', [1, 2], [1, 2]]
      Expect Select(1, 3, 'nc') ==# ['v', [1, 3], [1, 3]]
      Expect Select(1, 4, 'nc') ==# ['v', [1, 4], [1, 6]]
      Expect Select(1, 5, 'nc') ==# ['v', [1, 4], [1, 6]]
      Expect Select(1, 6, 'nc') ==# ['v', [1, 4], [1, 6]]
      Expect Select(1, 7, 'nc') ==# ['v', [1, 7], [1, 7]]
      Expect Select(1, 8, 'nc') ==# ['v', [1, 8], [1, 8]]
      Expect Select(1, 9, 'nc') ==# ['v', [1, 9], [1, 9]]

      Expect Select(2, 1, 'nc') ==# ['v', [2, 1], [2, 3]]
      Expect Select(2, 2, 'nc') ==# ['v', [2, 1], [2, 3]]
      Expect Select(2, 3, 'nc') ==# ['v', [2, 1], [2, 3]]
      Expect Select(2, 4, 'nc') ==# ['v', [2, 4], [2, 4]]
      Expect Select(2, 5, 'nc') ==# ['v', [2, 5], [2, 5]]
      Expect Select(2, 6, 'nc') ==# ['v', [2, 6], [2, 6]]
      Expect Select(2, 7, 'nc') ==# ['v', [2, 7], [2, 9]]
      Expect Select(2, 8, 'nc') ==# ['v', [2, 7], [2, 9]]
      Expect Select(2, 9, 'nc') ==# ['v', [2, 7], [2, 9]]

      Expect Select(3, 1, 'nc') ==# ['v', [3, 1], [3, 1]]
      Expect Select(3, 2, 'nc') ==# ['v', [3, 2], [3, 2]]
      Expect Select(3, 3, 'nc') ==# ['v', [3, 3], [3, 3]]
      Expect Select(3, 4, 'nc') ==# ['v', [3, 4], [3, 6]]
      Expect Select(3, 5, 'nc') ==# ['v', [3, 4], [3, 6]]
      Expect Select(3, 6, 'nc') ==# ['v', [3, 4], [3, 6]]
      Expect Select(3, 7, 'nc') ==# ['v', [3, 7], [3, 7]]
      Expect Select(3, 8, 'nc') ==# ['v', [3, 8], [3, 8]]
      Expect Select(3, 9, 'nc') ==# ['v', [3, 9], [3, 9]]
    end
  end

  context 'with "scan" = "forward"'
    it 'is targeted if it is under or following to the cursor'
      Expect Select(1, 1, 'nf') ==# ['v', [1, 4], [1, 6]]
      Expect Select(1, 2, 'nf') ==# ['v', [1, 4], [1, 6]]
      Expect Select(1, 3, 'nf') ==# ['v', [1, 4], [1, 6]]
      Expect Select(1, 4, 'nf') ==# ['v', [1, 4], [1, 6]]
      Expect Select(1, 5, 'nf') ==# ['v', [1, 4], [1, 6]]
      Expect Select(1, 6, 'nf') ==# ['v', [1, 4], [1, 6]]
      Expect Select(1, 7, 'nf') ==# ['v', [2, 1], [2, 3]]
      Expect Select(1, 8, 'nf') ==# ['v', [2, 1], [2, 3]]
      Expect Select(1, 9, 'nf') ==# ['v', [2, 1], [2, 3]]

      Expect Select(2, 1, 'nf') ==# ['v', [2, 1], [2, 3]]
      Expect Select(2, 2, 'nf') ==# ['v', [2, 1], [2, 3]]
      Expect Select(2, 3, 'nf') ==# ['v', [2, 1], [2, 3]]
      Expect Select(2, 4, 'nf') ==# ['v', [2, 7], [2, 9]]
      Expect Select(2, 5, 'nf') ==# ['v', [2, 7], [2, 9]]
      Expect Select(2, 6, 'nf') ==# ['v', [2, 7], [2, 9]]
      Expect Select(2, 7, 'nf') ==# ['v', [2, 7], [2, 9]]
      Expect Select(2, 8, 'nf') ==# ['v', [2, 7], [2, 9]]
      Expect Select(2, 9, 'nf') ==# ['v', [2, 7], [2, 9]]

      Expect Select(3, 1, 'nf') ==# ['v', [3, 4], [3, 6]]
      Expect Select(3, 2, 'nf') ==# ['v', [3, 4], [3, 6]]
      Expect Select(3, 3, 'nf') ==# ['v', [3, 4], [3, 6]]
      Expect Select(3, 4, 'nf') ==# ['v', [3, 4], [3, 6]]
      Expect Select(3, 5, 'nf') ==# ['v', [3, 4], [3, 6]]
      Expect Select(3, 6, 'nf') ==# ['v', [3, 4], [3, 6]]
      Expect Select(3, 7, 'nf') ==# ['v', [3, 7], [3, 7]]
      Expect Select(3, 8, 'nf') ==# ['v', [3, 8], [3, 8]]
      Expect Select(3, 9, 'nf') ==# ['v', [3, 9], [3, 9]]
    end
  end
end
