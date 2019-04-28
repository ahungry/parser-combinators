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
tag(Tag, Acc, Result) -->
  open_tag(Tag),
  {
    %DictChild = tag{ name: Tag },
    dict_create(DictChild, Tag, [name=Tag]),
    put_dict(child, Acc, DictChild, Result)
    % append(Acc, [Tag], Result)
  },
  close_tag(Tag).
tag(Tag, Child, Acc, Result) -->
  open_tag(Tag),
  {
    %DictChild = tag{ name: Tag },
    dict_create(DictChild, Tag, [name=Tag]),
    put_dict(child, Acc, DictChild, Acc2)

    % append(Acc, [Tag], Acc2)
  },
  (tag(Child, _, Acc2, Result) | tag(Child, Acc2, Result)),
  close_tag(Tag).

%phrase(tag(Tag, Child, tag{name:root}, Acc), "<strong><foo><bar><baz></baz></bar></foo></strong>").
% phrase(tag(Tag, Child), "<strong><foo><bar><baz></baz></bar></foo></strong>").

ws --> [W], { char_type(W, space) }, ws.
ws --> [].

any --> [].
any --> [_], any.
any([]) --> [].
any([H|T]) --> [H], any(T).
