% https://www.metalevel.at/prolog
% https://www.metalevel.at/prolog/dcg
% http://www.pathwayslms.com/swipltuts/dcg/

:- set_prolog_flag(double_quotes, chars).

identifier([H|T]) --> [H], { code_type(H, alpha) }, identifier(T).
identifier([]) --> [].

double_quote --> ['"'].
dq_ws --> ws, double_quote.
equals --> ['='].
attribute(R) --> dq_ws, identifier(K), equals, identifier(V), double_quote, { R = a{k: K, v: V} }.
% phrase(attribute(A), "  \"foo=bar\"").

attributes --> attributes(_, _).
attributes(Result) --> attributes([], Result).
attributes(Acc, Result) --> attribute(R1), { append(Acc, [R1], R2) }, attributes(R2, Result).
attributes(Result, Result) --> [].
% phrase(attributes([], R), "\"foo=bar\" \"baz=buz\"").

open_tag(Tag) --> open_tag(Tag, _).
open_tag(Tag, Attrs) --> "<", identifier(Tag), attributes(Attrs), ">".
open_tag(Tag, _) --> "<", identifier(Tag), ">".
close_tag(Tag) --> "</", identifier(Tag), ">".

tag --> tag(_).
tag(Result) -->
  open_tag(Tag, Attrs),
  { Dict = tag{ name: Tag, attrs: Attrs } },
  tags([], ChildResult),
  { put_dict(children, Dict, ChildResult, Result) },
  close_tag(Tag).
tag(Result) --> open_tag(Tag, Attrs), { Result = tag{ name: Tag, attrs: Attrs } }, close_tag(Tag).

tags --> tags(_, _).
tags(Acc, Result) --> tag(R1), { append(Acc, [R1], R2) }, tags(R2, Result).
tags(Result, Result) --> [].

% Working call to parse a list of tags even in recursive format.
% phrase(tags([], R), "<xml><x \"id=blub\" \"blub=dub\"></x><y></y></xml><foo><bar></bar></foo>").

ws --> [W], { char_type(W, space) }, ws.
ws --> [].

any --> [].
any --> [_], any.
any([]) --> [].
any([H|T]) --> [H], any(T).
