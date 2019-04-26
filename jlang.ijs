NB. https://www.jsoftware.com/help/learning/04.htm

require 'strings'

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

NB. https://code.jsoftware.com/wiki/Guides/Lexical_Closure
NB. u v x y
pair =: conjunction define
  smoutput 'uvxy'
  debug=: u;v;x;y
  smoutput debug
)

NB. A sample of lexical closure
burke=: 1 : 0
  n=. 'n_',(> cocreate''),'_'
  (n)=. m
  3 : (n,'=:',n,'+y')
)

NB. Again, sample with possible accumulation in lexical env
oleg=: 1 : 0
  a=. cocreate''
  n__a=: m
  a&(4 : 'n__x=: n__x + y')
)

NB. Similar to binding, but we could potentially do more inner calls?
NB. https://www.jsoftware.com/help/jforc/when_programs_are_data.htm
addX=: adverb define
  a=. cocreate''
  n__a=: m
  a&(4 : 'n__x + y')
  NB. This is syntax error, UGH!
  NB. a&addXverb
)

add9=: 9 addX
smoutput add9 i. 5

foo=: adverb define
  u (2 * y) NB. Monadic definition
:
  (3 * x) u (2 * y) NB. Dyadic definition
)

isOk=: 'ok' eq > 0 {
isErr=: 'err' eq > 0 {

bar=: conjunction define
  r1=: u y
  smoutput 'First result: '
  smoutput r1
  r2=: v r1
  smoutput 'Second result: '
  smoutput r2
  r2
:
  x u u v y NB. Dyadic definition
)
