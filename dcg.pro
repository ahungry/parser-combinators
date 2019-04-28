% https://www.metalevel.at/prolog
% https://www.metalevel.at/prolog/dcg
% http://www.pathwayslms.com/swipltuts/dcg/

:- set_prolog_flag(double_quotes, chars).

identifier([H|T]) -->
  [H],
  { code_type(H, alpha) },
  identifier(T).

identifier([]) --> [].

open_tag(Tag, Next) --> "<", identifier(Tag), ">", any(Next).

any([]) --> [].
any([H|T]) --> [H], any(T).

% phrase(open_tag, N).
