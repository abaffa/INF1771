%%%%%%%%%%%%%%%%%%
%%Generic Clauses
%%%%%%%%%%%%%%%%%%

ml([H|[]]):- write(H), nl.
ml([H|T]):- write(H), nl, ml(T).


%%Console output Items in a list.
outputList([H|[]], I) :- I1 is I+1, 
                         string_concat('plan. ', I1, X), 
                         write(X), 
                         nl, 
                         ml(H), 
                         nl, 
                         !.

outputList([H|T], I) :- I1 is I+1, 
                        string_concat('plan. ', I1, X), 
                        write(X), 
                        nl, 
                        ml(H), 
                        nl, 
                        outputList(T, I1).



%%findItem(List, Item, B) - Returns B = 1 if List has Item.
findItem([H|[]], H, 1) :- !.

findItem([H|[]], S, B) :- H \= S, 
                          B = 0, 
                          !.

findItem([H|_], S, B) :- H = S, 
                         B = 1, 
                         !.

findItem([H|T], S, B) :- H \= S, 
                         findItem(T, S, B).



%%concatenate sublists into one list
concatLists([H|[]], H) :- !.

concatLists([H|T], X) :- concatLists(T, X2), 
                         append(H, X2, X).



%%concatena politica
concatPolitica2([H, T], X) :- term_to_atom(H, H2), 
                              term_to_atom(T, T2), 
                              append([H2], ['-'], X2), 
                              append(X2, [T2], X3), 
                              concat_atom(X3, '', X).

concatPolitica([H|[]], H2) :- concatPolitica2(H, H2).

concatPolitica([H|T], X) :- concatPolitica(T, X2), 
                            concatPolitica2(H, H2), 
                            append([H2], [X2], X3), 
                            concat_atom(X3, ', ', X).



%%%maxA(List of possibilities, Action, Utility Estimative)
%%%return action that maximizes the utility estimative of a state based on a list of all possibilities
maxA([H|[]], A, VE) :- H = [A|VE].

maxA([H|T], A, VE) :- maxA(T, _, VE2), 
                      H = [A1|VE1], 
                      VE1 > VE2, 
                      A = A1, 
                      VE = VE1.

maxA([H|T], A, VE) :- maxA(T, A2, VE2), 
                      H = [_|VE1], 
                      VE1 =< VE2, 
                      A = A2, 
                      VE = VE2.



%%%minxA(List of possibilities, Action, Utility Estimative)
%%%return action that minimizes the utility estimative of a state based on a list of all possibilities
minA([H|[]], A, VE) :- H = [A|VE].

minA([H|T], A, VE) :- minA(T, _, VE2), 
                      H = [A1|VE1], 
                      VE1 < VE2, 
                      A = A1, 
                      VE = VE1.

minA([H|T], A, VE) :- minA(T, A2, VE2), 
                      H = [_|VE1], 
                      VE1 >= VE2, 
                      A = A2, 
                      VE = VE2.



saveFile(NAME, C) :- tell(NAME), 
                     write(C), 
                     told, 
                     style_check(-singleton), 
                     consult(NAME), 
                     !.



appendFile(NAME, C) :- append(NAME), 
                       write(C),
                       told,
                       style_check(-singleton),
                       consult(NAME),
                       !.



createPolTitle(P, P0) :- concatPolitica(P, P1), append(['#'], [P1], P2), concat_atom(P2, ', ', P0).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Math

sum([H|[]], H) :- !.

sum([H|T], S) :- sum(T, S2), 
                 S is S2 + H.



round(X, Y, Z) :- pow(10, Y, Y2), 
                  X2 is X * Y2, 
                  round(X2, X3), 
                  Z is X3 / Y2.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%