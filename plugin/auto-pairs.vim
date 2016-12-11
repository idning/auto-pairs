" Language:	JavaScript
" Maintainer:	JiangMiao <jiangfriend@gmail.com>
" Last Change:  2011-05-22
" Version: 1.0
" Repository: https://github.com/jiangmiao/auto-pairs
"
" Insert or delete brackets, parens, quotes in pairs.

if exists('g:AutoPairsLoaded') || &cp
  finish
end
let g:AutoPairsLoaded = 1

if !exists('g:AutoPairs')
  let g:AutoPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"'}

  let g:OpenPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"'}
  let g:ClosePairs = {')':'(', ']':'[', '}':'{',"'":"'",'"':'"'}

  let g:OpenBrackets= {'(':')', '[':']', '{':'}'}
  let g:CloseBrackets= {')':'(', ']':'[', '}':'{'}
end

" comment ) ] }
" comment ) ] }

function! AutoPairsInsert(key)
  let line = getline('.')
  let prev_char = line[col('.')-2]
  let pprev_char = line[col('.')-3]
  let current_char = line[col('.')-1]
  let next_char = line[col('.')]

  " ning: not process unknown chars
  "if !has_key(g:OpenPairs, a:key) && !has_key(g:ClosePairs, a:key)
      "return a:key
  "end

  if has_key(g:OpenBrackets, a:key)  " open 
      let open = a:key
      let close = g:OpenPairs[open]
      " ning: auto-pair if in end of line
      if col(".") == col("$")
          return open.close."\<Left>"
      end

      " input orig key
      return a:key
  end

  if has_key(g:CloseBrackets, a:key)  " close
      " Skip the character if current character is the same as input
      if current_char == a:key && prev_char == g:ClosePairs[a:key] && next_char != a:key
        return "\<Right>"
      end

      " input orig key
      return a:key
  end
  " ning: default skip:
  return a:key
  "return open.close."\<Left>"
endfunction

function! AutoPairsDelete()
  let line = getline('.')
  let prev_char = line[col('.')-2]
  let pprev_char = line[col('.')-3]

  if pprev_char == '\'
    return "\<BS>"
  end

  if has_key(g:AutoPairs, prev_char)
    let close = g:AutoPairs[prev_char]
    if match(line,'^\s*'.close, col('.')-1) != -1
      return "\<Left>\<C-O>cf".close
    end
  end

  return "\<BS>"
endfunction

function! AutoPairsJump()
  call search('[{("\[\]'')}]','W')
endfunction

function! AutoPairsMap(key)
    execute 'inoremap <silent> '.a:key.' <C-R>=AutoPairsInsert("\'.a:key.'")<CR>'
endfunction

function! AutoPairsInit()
  for [open, close] in items(g:AutoPairs)
    call AutoPairsMap(open)
    if open != close
      call AutoPairsMap(close)
    end
  endfor
  execute 'inoremap <silent> <BS> <C-R>=AutoPairsDelete()<CR>'
endfunction

call AutoPairsInit()
