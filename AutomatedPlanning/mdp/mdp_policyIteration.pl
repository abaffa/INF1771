%%%%%%%%%%%%%%%%%%
%%Policy Iteration
%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%

existBetterA(S0, A, VE) :- findall(X, t(X, S0, _, _), V), 
                           betterA(V, S0, A, VE).

betterA([H|[]], S0, A, VE) :- ep(S0, VEP),
                              q(S0, H, VQ), 
                              (
                                 (
                                    VQ > VEP,
                                    A = H, 
                                    VE = VQ,
                                    !
                                 ); 
                                 (
                                    p(P),
                                    nextFromPol(P, S0, _, A0),
                                    VQ =< VEP,
                                    A = A0,
                                    VE = VEP,
                                    !
                                 )
                              ).

betterA([H|T], S0, A, VE) :- (
                                ep(S0, VEP),
                                q(S0, H, VQ), 
                                VQ > VEP,
                                A = H, 
                                VE = VQ,
                                !
                             );
                             betterA(T, S0, A, VE).



existWorseA(S0, A, VE) :- findall(X,t(X, S0 ,_ ,_), V),
                          worseA(V, S0, A, VE).

worseA([H|[]], S0, A, VE) :- ep(S0, VEP),
                             q(S0, H, VQ),
                             (
                                (
                                   VQ < VEP,
                                   A = H,
                                   VE = VQ,
                                   !
                                );
                                (
                                   p(P),
                                   nextFromPol(P, S0, _, A0),
                                   VQ >= VEP, 
                                   A = A0, 
                                   VE = VEP,
                                   !
                                )
                             ).

worseA([H|T], S0, A, VE) :- (
                               ep(S0, VEP),
                               q(S0, H, VQ), 
                               VQ < VEP,
                               A = H, 
                               VE = VQ,
                               !
                            );
                            betterA(T,S0,A,VE).



%%Change current action from a Policy
changePolActions(P, P0) :- findall(X, s(X), S), 
                           changePolActions(S, P, P0).

changePolActions([S0|[]], P, P0) :- existBetterA(S0, A0, _),
                                    changePolAction(P, S0, A0, P0),
                                    !.

changePolActions([S0|T], P, P0) :- changePolActions(T, P, P2),
                                   existBetterA(S0, A0, _),
                                   changePolAction(P2, S0, A0, P0).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Q Functions


/* cabecalho para unica chamada */

createQHeader(S0, A0, X) :- upcase_atom(S0, V0),
                            Z = ['q(', S0, ', ', A0, ', ', V0, ') :- '],
                            concat_atom(Z, '', X).



/* monta Q Probs */
createQProbs(P, S0, X):- findall(Z, 
                                   (
                                      nextFromPol(P, S0, S1, A),
                                      t(A, S0, S1, PB), 
                                      upcase_atom(S1, V1),
                                      Z = [' + (', PB, ' * ', V1, ')']
                                   ), 
                               X1),
                         concatLists(X1, X2),
                         concat_atom(X2, ' ', X3),
			 X4 = ['(0', X3, ')'], 
                         concat_atom(X4, '', X),
                         !.


/* monta Equacao */
createQEquation(P, S0, D, Q) :- createQProbs(P, S0, T),
                                nextFromPol(P, S0, S1, A),
                                cost(A, S0, C),
                                r(S0, RW), 
                                upcase_atom(S0, V0),
                                X = [V0, ' = (', RW, ' - ', C, ') + ', D, ' * ', T],
                                concat_atom(X,' ', Q),
                                !.


/* monta todas equacoes (para cada estado) */
createQEquations(P, D, Z3) :- findall(X, 
                                        (
                                           s(S0),
                                           createQEquation(P, S0, D, X)
                                        ),
                                     Z),
                              sort(Z, Z2),
                              concat_atom(Z2, ', \n\t', Z3).



/* monta Qs */
createQ(P, D, S0, Z) :- createQEquations(P, D, T1),
                        append(['{'], [T1], T2),
                        append(T2, ['}.'], T),
                        nextFromPol(P, S0, _, A),
                        term_to_atom(A, A0),
                        createQHeader(S0, A0, C),
                        concatLists([[C], T], X2),
                        concat_atom(X2, '', Z).



createAllQ(P,D,S0,Z) :- findall(X,
                                  (
                                     t(A, S0, _, _),
                                     changePolAction(P, S0, A, P0),
                                     createQ(P0, D, S0, X)
                                  ),
                              Z2),
                        sort(Z2, Z3),
                        concat_atom(Z3, '\n', Z).



createAllQfromS(P, D, Z) :- findall(X, (s(S0), createAllQ(P, D, S0, X)), Z2),
                            sort(Z2, Z3),
                            concat_atom(Z3, '\n', Z).



saveQ(P, D) :- createPolTitle(P, P3),
               createAllQfromS(P, D, Z),
               append([P3], [Z], Z2),
               concat_atom(Z2, '\n', Z3),
               saveFile('./q.txt', Z3),
               !.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Ep Functions


/* monta condicoes de saida da resposta */
createEpCondition(S0, X) :- upcase_atom(S0, V0), 
                            Z = ['(S0 = ', S0, ', ', 'X = ', V0, ')'], 
                            concat_atom(Z, '', X).



createEpConditions(X) :- findall(Z, (s(S0), createEpCondition(S0, Z)), X1), 
                         concat_atom(X1, '; ', X2), 
                         X3 = ['(', X2, ')'], 
                         concat_atom(X3, '', X).




/* monta parenteses Probabilidade */
createEpProbs(P, S0, X) :- findall(Z, 
                                     (
                                        nextFromPol(P, S0, S1, A), 
                                        t(A, S0, S1, PB), 
                                        upcase_atom(S1, V1), 
                                        Z = ['+(', PB, '*', V1, ')']
                                     ), 
                                 X1), 
                           concatLists(X1, X2), 
                           concat_atom(X2, ' ', X3), 
                           X4 = ['(0', X3, ')'], 
                           concat_atom(X4, '', X), !.


/* monta Equacao */
createEpEquation(P, S0, D, Q) :- createEpProbs(P, S0, T), 
                                 nextFromPol(P, S0, S1, A), 
                                 c(A, S0, C), 
                                 r(S0, RW), 
                                 upcase_atom(S0, V0), 
                                 X = [V0, ' = (', RW, ' - ', C, ') + ', D, ' * ', T], 
                                 concat_atom(X, ' ', Q), !.



/* monta todas equacoes (para cada estado) */
createEpEquations(P, D, Z3) :- findall(X, (s(S0), createEpEquation(P, S0, D, X)), Z), 
                               sort(Z, Z2), 
                               concat_atom(Z2, ', \n\t', Z3).


/* monta Ep */
createEpHeader(X) :- createEpConditions(Y),
                     Z = ['ep(S0, X) :- ', Y],
                     concat_atom(Z, '', X).



createEp(P, D, Z) :- createEpEquations(P,D,T1),
                     append(['{'], [T1], T2),
                     append(T2, ['}, !.'] ,T),
                     createEpHeader(C),
                     concatLists([[C], [', \n\t'], T], X2),
                     concat_atom(X2, '', Z).



saveEp(P, D) :- createPolTitle(P, P3),
                createEp(P, D, Z),
                append([P3], [Z], Z2),
                concat_atom(Z2, '\n', Z3),
                saveFile('./ep.txt', Z3),
                !.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Policy Iteration Algoritm


%polIt(0.9, P0).

polIt(D,P0) :- (pol(P), !),
               polIt(P,D,P0).

polIt(P,D,P0) :- write('\n'),
                 write('**********************\n'),
                 write('Policy Iteration\n'),
                 write('**********************\n'),
                 saveP(P), 
                 polIt2(D, 0, P0),
                 !.

polIt2(D,I,P0):- I2 is I + 1,
                 string_concat('\n***Trying policy #', I2, X1), string_concat(X1,'...\n', X), write(X),
                 p(P),
                 saveQ(P, D),
                 saveEp(P, D),
                 changePolActions(P, P1),
                 (
                   (
                       P \= P1, 
                       saveP(P1), 
                       polIt2(D, I2, P0)
                   );
                   (
                       P = P1, 
                       P0 = P1,
                       !
                   )
                 ).


%

