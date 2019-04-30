% https://www.metalevel.at/prolog/dcg
% http://www.pathwayslms.com/swipltuts/dcg/

:- use_module(library(pio)).
% Well, requiring this gets us the json stuff.
:- use_module(library(http/json)).
:- set_prolog_flag(double_quotes, chars).

identifier([H|T]) --> [H], { code_type(H, alpha) ; H = '-' }, identifier(T).
identifier([]) --> [].

double_quote --> ['"'].
dq_ws --> ws, double_quote.
equals --> ['='].
attribute(R) --> ws, identifier(K), ws, equals, dq_ws, any(V), double_quote, {
                   string_chars(SV, V),
                   string_chars(SK, K),
                   R = attr{key: SK, val: SV}
                 }.
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
self_tag(Tag, Attrs) --> "<", identifier(Tag), attributes(Attrs), ws, "/>".

tag --> tag(_).
tag(Result) -->
  open_tag(Tag, Attrs),
  {
    string_chars(STag, Tag),
    Dict = tag{ name: STag, attrs: Attrs }
  },
  tags([], ChildResult),
  { put_dict(children, Dict, ChildResult, Result) },
  close_tag(Tag).
tag(Result) --> open_tag(Tag, Attrs), {
                  string_chars(STag, Tag),
                  Result = tag{ name: STag, attrs: Attrs }
                }, close_tag(Tag).
tag(Result) --> self_tag(Tag, Attrs), {
                  string_chars(STag, Tag),
                  Result = tag{ name: STag, attrs: Attrs }
                }.

tags --> tags(_, _).
tags(Result) --> tags([], Result).
tags(Acc, Result) --> ws, tag(R1), ws, { append(Acc, [R1], R2) }, tags(R2, Result).
tags(Result, Result) --> [].

% Working call to parse a list of tags even in recursive format.
% phrase(tags(R), "<xml><x \"id=blub\" \"blub=dub\"></x><y></y></xml><foo><bar></bar></foo>").

ws --> [W], { char_type(W, space) }, ws.
ws --> [].

any --> [].
any --> [_], any.
any([]) --> [].
any([H|T]) --> [H], any(T).

sample("
<top label=\"Top\">
  <semi-bottom label=\"Bottom\"/>
  <middle>
    <bottom label=\"Another bottom\"/>
  </middle>
</top>
").
main(O) :- sample(I), phrase(tags(O), I).
main_file(O) :-phrase_from_file(tags(O), 'doc.xml'). % Fails for some reason?

to_json :-
  main(O),
  %open('/tmp/foo.json', write, OutStream),
  open('/dev/stdout', write, OutStream),
  json:json_write_dict(OutStream, O, [tag(type)]),
  close(OutStream).
  %reply_json(O).
  %format('~w~n', [O]).
