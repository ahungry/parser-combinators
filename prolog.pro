% https://www.metalevel.at/prolog
:- use_module(lambda).

compose(F,G, FG) :-
  FG =  \X^Z^(call(G,X,Y), call(F,Y,Z)).

add_one(I, O) :- O is I + 1.
add_two(I, O) :- O is I + 2.

do_compose(Y) :-
  compose(add_one, add_two, F),
  call(F, Y).

ok(Next, Result, OK) :- OK = [ok, Next, Result].
err(Msg, Err) :- Err = [err, Msg].

the_letter_a(S) :-
  string_codes(S, [LH | _]),
  LH = 97.

the_letter(L, S) :-
  string_codes(S, [LH | _]),
  L = LH.

take([], R, _, R).
take([_ | _], Acc, N, Result) :-
  N < 1,
  take([], Acc, 0, Result).
take([H | T], Acc, N, Result) :-
  N > 0,
  append(Acc, [H], Acc2),
  N2 is N - 1,
  take(T, Acc2, N2, Result).

take_after(T, N, T) :-
  N < 1.
take_after([_ | T], N, Result) :-
  N > 0,
  N2 is N - 1,
  take_after(T, N2, Result).

slice_string(S, N, Sliced) :-
  string_codes(S, Ss),
  take(Ss, [], N, Ss2),
  string_codes(Sliced, Ss2).

slice_string_after(S, N, Sliced) :-
  string_codes(S, Ss),
  take_after(Ss, N, Ss2),
  string_codes(Sliced, Ss2).

match_literal(Match, String, Result) :-
  sub_string(String, 0, _, _, Match),
  string_length(Match, Mlen),
  slice_string_after(String, Mlen, Sliced),
  ok(Sliced, Match, Result).

identifiers("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-").

is_identifier(C) :-
  identifiers(Ids),
  string_codes(Ids, Idcs),
  member(C, Idcs).

identifier(L, Acc, Ok) :-
  [H|_] = L,
  \+is_identifier(H),
  ok(L, Acc, Ok).

identifier([H|T], Acc, Ok) :-
  is_identifier(H),
  append(Acc, [H], Acc2),
  identifier(T, Acc2, Ok).

identifier([], Ok) :- ok([], [], Ok).
identifier(S, Ok) :-
  string_codes(S, Ss),
  identifier(Ss, [], OkRaw),
  [_, NextCodes, ResultCodes] = OkRaw,
  string_codes(Next, NextCodes),
  string_codes(Result, ResultCodes),
  ok(Next, Result, Ok).

is_ok([ok | _]).
is_err([err | _]).

pair(Goal1, Goal2, Input, Output) :-
  call(Goal1, Input, G1),
  is_ok(G1),
  [_, Next1, Result1] = G1,
  call(Goal2, Next1, G2),
  is_ok(G2),
  [_, Next2, Result2] = G2,
  ok(Next2, [Result1, Result2], Output).

ml_tag_open(String, Result) :- match_literal("<", String, Result).

tag_opener(String, Result) :-
  pair(ml_tag_open, identifier, String, Result).

take_left([L,_|_], L).
take_right([_,R|_], R).

map(MaybeOk, Fn, Output) :-
  is_ok(MaybeOk),
  [_, Next, Result] = MaybeOk,
  call(Fn, Result, ResultFn),
  ok(Next, ResultFn, Output).

left(Parser1, Parser2, Input, Output) :-
  pair(Parser1, Parser2, Input, Out1),
  map(Out1, take_left, Output).

right(Parser1, Parser2, Input, Output) :-
  pair(Parser1, Parser2, Input, Out1),
  map(Out1, take_right, Output).

ltag_opener(String, Result) :- left(ml_tag_open, identifier, String, Result).
rtag_opener(String, Result) :- right(ml_tag_open, identifier, String, Result).

% :- debug.
zero_or_more(Parser, Input, Acc, Result) :-
  call(Parser, Input, R1),
  \+is_ok(R1),
  ok(Acc, Input, Result).

% TODO Fix issue with ZOM
zero_or_more(Parser, Input, Acc, Result) :-
  call(Parser, Input, R1),
  is_ok(R1),
  [_, Next, R] = R1,
  format('~w~n', R),
  append(Acc, [R], Acc2),
  format('~w~n', Next),
  zero_or_more(Parser, Next, Acc2, Result).

zom_rtag_opener(String, Result) :-
  zero_or_more(rtag_opener, String, [], Result).

ml_haha(S, R) :- match_literal("ha", S, R).
zom_ml_haha(S, R) :- zero_or_more(ml_haha, S, [], R).
