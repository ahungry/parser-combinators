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

take_after(L, 0, L).
take_after([_ | T], N, Result) :-
  N < 1,
  take_after(T, 0, Result).
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

is_identifier([]).
is_identifier([C | T]) :-
  identifiers(Ids),
  string_codes(Ids, Idcs),
  member(C, Idcs),
  is_identifier(T).

identifier(S) :-
  string_codes(S, Ss),
  is_identifier(Ss).


dot(_) --> ".".
