% https://www.metalevel.at/prolog

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

% TODO Make sure this returns up to first non-match
is_identifier(C) :-
  identifiers(Ids),
  string_codes(Ids, Idcs),
  member(C, Idcs).

identifier([], Ok) :- ok([], [], Ok).

identifier([H|T], Ok) :-
  \+is_identifier(H),
  ok(T, [H], Ok).

identifier([H|T], Ok) :-
  is_identifier(H),
  identifier(T, Ok).

identifier(S, Ok) :-
  string_codes(S, Ss),
  identifier(Ss, OkRaw),
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
  ok(Next2, [Result1, Result2, Next1, Next2], Output).

ml_tag_open(String, Result) :- match_literal("<", String, Result).

tag_opener(String, Result) :-
  pair(ml_tag_open, identifier, String, Result).


dot(_) --> ".".
