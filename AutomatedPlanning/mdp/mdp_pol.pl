%%%%%%%%%%%%%%%%%%%%%%
%MDP based Planner
%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Creates a list P of policies
pols(P) :- findall(X, pol(X), P).



%%Creates many Policies P using backtracking
pol(P) :- findall(X, s(X), P0),
         pol(P0,P).

pol(S, P) :- pol(S, [], P).

pol([S0|[]], P0, P1) :- t(A, S0, _, _), 
                        P1 = [[S0,A]|P0].

pol([S0|T], P0, P1) :- pol(T, P0, P), 
                       t(A, S0, _, _), 
                       P1 = [[S0,A]|P].


%%Save actual Policy
saveP(P) :- term_to_atom(P, PP), 
            Z=['p(P):- P=', PP, '.\n'],
            concat_atom(Z, C), 
            saveFile('./p.txt', C).


%%Show all available policies
showPols :- pols(X),
            outputList(X, 0).



%%nextFromPol(Policy, Initial State, Final State)
nextFromPol([P|T], S0, S1) :- (P = [S0|[A]], t(A, S0, S1, _)); 
                              nextFromPol(T, S0, S1).

%%nextFromPol(Policy, Initial State, Final State, Action)
nextFromPol([P|T], S0, S1, A) :- (P = [S0|[A]], t(A, S0, S1, _)); 
                                 nextFromPol(T, S0, S1, A).


%%Change current action from a Policy
%%changePolAction(Policy, State, Action, NewPol).
changePolAction([H|[]], S0, A0, P1) :- [S, _] = H, 
                                      (
                                         ( 
                                            S0 = S,
                                            H2 = [S, A0]
                                         );
                                         (
                                            S0 \= S,
                                            H2 = H
                                         )
                                      ),
                                      P1 = [H2],
                                      !.

changePolAction([H|T], S0, A0, P1) :- changePolAction(T, S0, A0, [HX|TX]),
                                     [S, _] = H, 
                                     (
                                        ( 
                                           S0 = S,
                                           H2 = [S, A0],
                                           !
                                        );
                                        (
                                           S0 \= S,
                                           H2 = H
                                        )
                                     ),
                                     P1 = [H2, HX|TX].



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%List Histories based on a Policy
%%h(Policy, Initial State, Horizon, History)
h(P, S0, 1, H) :- nextFromPol(P, S0, S1), 
                  H = [S1].

h(P, S0, N, H) :- N > 0, 
                  N1 is N-1,
                  nextFromPol(P, S0, S1),
                  h(P, S1, N1, H1),
                  H = [S1|H1].

%%h(Policy, History) - Uses Horizon = 5 states.
h(P, H) :- nextFromPol(P, S0, _),
           h(P, S0, 5, H1), %define aqui horizonte 
           H = [S0|H1]. 



%%prob(Action, Final State, Initial State, Probability) - Returns Probability
prob(A, S1, S0, PROB) :- t(A, S0, S1, PROB).



%%cost(Action, Final State, Initial State, Cost) - Returns Cost
cost(A, S0, C) :- c(A, S0, C).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hist2(P, S0, S0, D, N, H, V, PB) :- N > 0, 
                                    nextFromPol(P, S0, S1, A), 
                                    R = 0, 
                                    H = [S0], 
                                    cost(A, S0, C), 
                                    prob(A, S1, S0, PB), 
                                    V1 is R - C , 
                                    V is ((D ^ N) * V1),  
                                    VD is (round((D ^ N) * (10 ^ 14)) / (10 ^ 14)),
                                    VD = 0,
                                    !.

hist2(P, S0, S0, D, N, H, V, PB) :- N > 0, 
                                    nextFromPol(P, S0, S1, A), 
                                    S0 \= S1, 
                                    R = 0, 
                                    cost(A, S1, C), 
                                    prob(A, S0, S1, PB1), 
                                    V1 is R - C, 
                                    VD is ((D ^ N) * V1), 
                                    N2 is N + 1, 
                                    hist(P, S0, S1, D, N2, H1, V2, PB2), 
                                    PB is PB2 * PB1,
                                    V is V2 + VD, 
                                    H = [S1|H1].

hist2(P, S0, S0, D, N, H, V, PB) :- N > 0, 
                                    nextFromPol(P, S0, S0, A), 
                                    R = 0, 
                                    cost(A, S0, S0, C), 
                                    prob(A, S0, PB1), 
                                    V1 is R - C, 
                                    VD is ((D ^ N) * V1), 
                                    N2 is N + 1, 
                                    hist2(P, S0, S0, D, N2, H1, V2, PB2),
                                    PB is PB2 * PB1,
                                    V is V2 + VD, 
                                    H = [S0|H1].



hist(P, S_1, S0, D, N, H, V, PB) :- N > 0, 
                                    nextFromPol(P, S0, S1, A), 
                                    S_1 \= S0, 
                                    r(S0, R), 
                                    H = [S0], 
                                    cost(A, S0, C), 
                                    prob(A, S1, S0, PB), 
                                    V1 is R - C, 
                                    V is ((D ^ N) * V1), 
                                    VD is (round((D ^ N) * (10 ^ 14)) / (10 ^ 14)),
                                    VD=0,
                                    !.

hist(P, S0, S0, D, N, H, V, PB) :- N > 0, 
                                   nextFromPol(P, S0, S1, A), 
                                   S0 = S1, 
                                   r(S0, R1), 
                                   R1 < 0, 
                                   R = 0, 
                                   H = [S0], 
                                   cost(A, S1, C), 
                                   prob(A, S0, S1, PB), 
                                   V1 is R - C, 
                                   V is ((D ^ N) * V1), 
                                   VD is (round((D ^ N) * (10 ^ 14)) / (10 ^ 14)),
                                   VD = 0,
                                   !.

hist(P, S0, S0, D, N, H, V, PB) :- N > 0, 
                                   nextFromPol(P, S0, S1, A), 
                                   S0 = S1, 
                                   r(S0, R1), 
                                   R1 >= 0, 
                                   R = R1, 
                                   H = [S0], 
                                   cost(A, S1, C), 
                                   prob(A, S0, S1, PB), 
                                   V1 is R - C, 
                                   V is ((D ^ N) * V1), 
                                   VD is (round((D ^ N) * (10 ^ 14)) / (10 ^ 14)),
                                   VD = 0,
                                   !.



hist(P, S_1, S0, D, N, H, V, PB) :- N > 0, 
                                    nextFromPol(P, S0, S1, A),
                                    S_1 \= S0, 
                                    r(S0, R), 
                                    cost(A, S0, C), 
                                    prob(A, S1, S0, PB1), 
                                    V1 is R - C, 
                                    VD is ((D ^ N) * V1), 
                                    N2 is N + 1, 
                                    hist(P, S0, S1, D, N2, H1, V2, PB2),
                                    PB is PB2 * PB1,
                                    V is V2 + VD, 
                                    H = [S1|H1].

hist(P, S0, S0, D, N, H, V, PB) :- N > 0,
                                   nextFromPol(P, S0, S1, A),  
                                   S0 = S1, 
                                   r(S0, R1), 
                                   R1 < 0, 
                                   R = 0, 
                                   cost(A, S1, C), 
                                   prob(A, S0, S1, PB1), 
                                   V1 is R - C, VD is ((D ^ N) * V1), 
                                   N2 is N + 1, 
                                   hist(P, S0, S1, D, N2, H1, V2, PB2), 
                                   PB is PB2 * PB1,
                                   V is V2 + VD, 
                                   H = [S1|H1].

hist(P, S0, S0, D, N, H, V, PB) :- N > 0,
                                   nextFromPol(P, S0, S1, A), 
                                   S0 = S1, 
                                   r(S0, R1), 
                                   R1 >= 0,
                                   R = R1, 
                                   cost(A, S1, C), 
                                   prob(A, S0, S1, PB1), 
                                   V1 is R - C, 
                                   VD is ((D ^ N) * V1), 
                                   N2 is N + 1, 
                                   hist(P, S0, S1, D, N2, H1, V2, PB2), 
                                   PB is PB2 * PB1,
                                   V is V2 + VD, 
                                   H = [S1|H1].



hist(P, S0, S0, D, 0, H, V, PB) :- N = 0,
                                   nextFromPol(P, S0, S1, A), 
                                   S0 \= S1, 
                                   R = 0, 
                                   cost(A, S0, C), 
                                   prob(A, S1, S0, PB1), 
                                   V1 is R - C, 
                                   VD is ((D ^ N) * V1), 
                                   N2 is N + 1, 
                                   hist(P, S0, S1, D, N2, H1, V2, PB2), 
                                   PB is PB2 * PB1,
                                   V is V2 + VD, 
                                   H = [S1|H1].

hist(P, S0, S0, D, 0, H, V, PB) :- N = 0,
                                   nextFromPol(P,S0,S1,A), 
                                   S0 = S1, 
                                   R = 0, 
                                   cost(A, S0, C), 
                                   prob(A, S1, S0, PB1),
                                   V1 is R - C, 
                                   VD is ((D ^ N) * V1), 
                                   N2 is N + 1, 
                                   hist2(P, S0, S1, D, N2 , H1, V2, PB2), 
                                   PB is PB2 * PB1,
                                   V is V2 + VD, 
                                   H = [S1|H1].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%hist(Policy, Initial State, Discount Factor, History, Utility Value, Probability)
hist(P, S0, D, H, V, PB) :- hist(P, S0, S0, D, 0, H1, V, PB2), 
                            PB1 = 1, 
                            PB is PB2 * PB1, 
                            H = [S0|H1].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%e(Policy, Discount Factor, Utility Estimative)
%%Returns Utility Estimative from a Policy based on a Discount Factor
e(P, D, E) :- e(s1, P, D, E).

e(S0, P, D, E) :- findall(X, (hist(P, S0, D, _, V, PB), X is V * PB), Z),
                  e2(Z, E),
                  !.

e2([E|[]], E).

e2(V, E) :- V = [E1|ST], 
            e2(ST, E2),
            E is E2 + E1.

