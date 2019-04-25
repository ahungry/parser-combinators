NB. https://www.jsoftware.com/help/learning/04.htm

txt =: 0 : 0
What is called a "script" is
a sequence of lines of J.
)

T=:212

script =: 0 : 0
t =: T - 32
t * 5 % 9
)

do =: 0 !: 1

do script
T=:32
do script

OK =: 3 : 0 NB. A monadic fn
  'ok';  (> {. y) ; < (}. y)
)
ERR =: 3 : 0
  'err'; y
)

theLetterA =: 3 : 0
  if. 'a' = {.y
  do. OK 'a'
  else. ERR y
  end.
)

theLetter =: 4 : 0
  if. x = {. y
  do. OK x ; (}. y)
  else. ERR y
  end.
)

NB. Basically a HOF here, by bonding a dyadic to a monadic.
tla =: 'a' & theLetter

eq =: 4 : 0
  if. (# x) = (# y)
  do. x = y
  else. 0
  end.
)

matchLiteral =: 4 : 0
  fn=. x & theLetter
  fr=. fn y
  res=. > 0 { fr
  if. 'ok' eq res
  do. fr
  else. ERR y
  end.
)
