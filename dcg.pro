% https://www.metalevel.at/prolog
% https://www.metalevel.at/prolog/dcg
% http://www.pathwayslms.com/swipltuts/dcg/

:- set_prolog_flag(double_quotes, chars).

identifier([H|T]) -->
  [H],
  { code_type(H, alpha) },
  identifier(T).

identifier([]) --> [].

dtest(I, O) :-
  D = foo{ x: I},
  put_dict(y, D, 5, D2),
  O is D2.x + D2.y.

% TODO Need to make a usable nest format.
% For some reason, the dict
open_tag(Tag) --> "<", identifier(Tag), ">".
close_tag(Tag) --> "</", identifier(Tag), ">".

tag --> tag(_).
tag(Result) -->
  open_tag(Tag),
  { Result = tag{ name: Tag } },
  close_tag(Tag).
tag(Result) -->
  open_tag(Tag),
  { Dict = tag{ name: Tag } },
  tag(ChildResult),
  { put_dict(child, Dict, ChildResult, Result) },
  close_tag(Tag).

tags --> [].
tags --> tag, tags.

% phrase(tag(_, Result), "<strong><foo><bar><baz></baz></bar></foo></strong>").

ws --> [W], { char_type(W, space) }, ws.
ws --> [].

any --> [].
any --> [_], any.
any([]) --> [].
any([H|T]) --> [H], any(T).
