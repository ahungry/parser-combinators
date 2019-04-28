% https://www.metalevel.at/prolog
% https://www.metalevel.at/prolog/dcg
% http://www.pathwayslms.com/swipltuts/dcg/

:- set_prolog_flag(double_quotes, chars).

identifier([H|T]) -->
  [H],
  { code_type(H, alpha) },
  identifier(T).

identifier([]) --> [].

open_tag(Tag) --> "<", identifier(Tag), ">".
close_tag(Tag) --> "</", identifier(Tag), ">".
tag(Tag, Acc, Result) -->
  open_tag(Tag),
  { append(Acc, [Tag], Result) },
  close_tag(Tag).
tag(Tag, Child, Acc, Result) -->
  open_tag(Tag),
  { append(Acc, [Tag], Acc2) },
  (tag(Child, _, Acc2, Result) | tag(Child, Acc2, Result)),
  close_tag(Tag).

% phrase(tag(Tag, Child), "<strong><foo><bar><baz></baz></bar></foo></strong>").

ws --> [W], { char_type(W, space) }, ws.
ws --> [].

any --> [].
any --> [_], any.
any([]) --> [].
any([H|T]) --> [H], any(T).
