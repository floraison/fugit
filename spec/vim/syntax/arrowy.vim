
"
" in .vimrc :
"   set runtimepath+=test/vim/
"
" place at the end of _xxx_tree.txt or _xxx_eval.txt:
"   # vim: syntax=arrowy
"

  " (<pattern>)@<=<match>  ~~~ positive lookbehind
  " <match>(<pattern>)@=   ~~~ positive lookahead
  " (<pattern>)@!<match>   ~~~ negative lookbehind
  " <match>(<pattern>)@!   ~~~ negative lookahead

hi! default link aroComment Comment
hi! default link aroEndComment Comment
hi! aroCode cterm=NONE ctermfg=green ctermbg=16
hi! aroArrow cterm=NONE ctermfg=blue ctermbg=16
hi! aroOutcome cterm=NONE ctermfg=darkgreen ctermbg=16
hi! aroContext cterm=NONE ctermfg=darkgrey ctermbg=16

syn match aroComment '\v^ *#[^\n]*\n'
syn match aroCode '\v^[^\U27f6#]+(%U27f6)@='
syn match aroArrow '\v%U27f6'
syn match aroContext '\v(%U27f6)@<=[^\U27f6]+(%U27f6)@='
syn match aroEndComment '\v#[^\n]*\n' contained
syn match aroOutcome '\v(%U27f6)@<=[^\U27f6]+$' contains=aroEndComment

let b:current_syntax = "arrowy"

