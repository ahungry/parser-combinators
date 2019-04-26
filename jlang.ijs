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
  NB. 'ok';  (> {. y) ; < (}. y)
  'ok';  (> {. y) ; (}. y)
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
  smoutput 'Letter: ' ; x
  if. x = {. y
  do. OK x ; (}. y)
  else. ERR y
  end.
)

NB. Basically a HOF here, by bonding a dyadic to a monadic.
tla =: 'a' & theLetter

NB. A dyadic string equality check
eq =: 4 : 0
  if. (# x) = (# y)
  do. (# x) = (+/ x = y)
  else. 0
  end.
)

matchLiteral =: 4 : 0
  xlen=. # x
  ylen=. # y
  result=. xlen $ y
  next=. |. ((ylen - xlen) $ (|. y)) NB. Keep last set of chars.
  if. x eq result
  do. OK next ; result
  else. ERR y
  end.
)

ascii=:1 2 3 { 8 32 $ a.
asciiFlat=: (0 { ascii) , (1 { ascii) , (2 { ascii)

identifiers=: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-'
isAlphaNum=: 3 : ('0 = # (#~ 62 = identifiers i. y)')
isNotAlphaNum=: 3 : ('-. isAlphaNum y')

xisAlphaNum=: 3 : ('(identifiers i. y)')

indexOf=: (i.&'x')
openTag =: '<' & matchLiteral

NB. toupper / tolower
identifier =: 3 : 0
  ylen=. # y
  keepN=. # (# identifiers) taketo (identifiers i. y)
  result=. keepN $ y
  next=. |. ((ylen - keepN) $ (|. y))
  OK next ; result
)

pair =: 4 : 0
  parser1=. x
  parser2=. y
  r1=. parser1
)
