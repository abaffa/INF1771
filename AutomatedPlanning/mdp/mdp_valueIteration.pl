%%%%%%%%%%%%%%%%%%
%%Value Iteration
%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%

maxQ(S0, A, VE) :- findall(X, (q(S0, A, E), X = [A|E]), V), 
                   maxA(V, A, VE),
                   !.

minQ(S0, A, VE) :- findall(X, (q(S0, A, E), X = [A|E]), V),
                   minA(V, A, VE),
                   !.



%%Change current action from a Policy
changePolActions(P, P0) :- findall(X, s(X), S),
                           changePolActions(S, P, P0).

changePolActions([S0|[]], P, P0) :- maxQ(S0, A0, _),
                                    changePolAction(P, S0, A0, P0),
                                    !.

changePolActions([S0|T], P, P0) :- changePolActions(T, P, P2),
                                   maxQ(S0, A0, _),
                                   changePolAction(P2, S0, A0, P0).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Q Functions

/* cabecalho para unica chamada */
createQCondition(S0, I, X) :- upcase_atom(S0, V0), 
                              Z = ['ek(', S0, ', ', I, ', ', 'Ek_1_', V0, ')'], 
                              concat_atom(Z,'', X).



createQConditions(I, X) :- findall(Z, 
                                     (
                                        s(S0), 
                                        createQCondition(S0, I, Z)
                                     ), 
                                 X1),
                           concat_atom(X1,', ', X2),
                           X3 = ['(', X2, ')'], 
                           concat_atom(X3, '', X).



createQHeader(S0, A0, I, X) :- I0 is I - 1,
                               createQConditions(I0, Y),
                               upcase_atom(S0, V0),
                               Z=['q(', S0, ', ', A0, ', X) :- X = ', V0, ', ', Y],
                               concat_atom(Z, '', X).



/* monta Q Probs */
createQProbs(P, S0, X) :- findall(Z, 
                                    (
                                       nextFromPol(P, S0, S1, A),
                                       t(A, S0, S1, PB), 
                                       upcase_atom(S1, V1),
                                       concat_atom(['Ek_1_', V1], V2), 
                                       Z = [' + (', PB, ' * ', V2, ')']
                                    ), 
                                X1), 
                          concatLists(X1, X2), 
                          concat_atom(X2, ' ', X3),
                          X4 = ['(0', X3, ')'], 
                          concat_atom(X4, '', X),
                          !.



/* monta Equacao */
createQEquation(P,S0,D,Q) :- createQProbs(P,S0,T),
                             nextFromPol(P, S0, S1, A),
                             c(A, S0, C),
                             r(S0, RW), 
                             upcase_atom(S0, V0),
                             X = [V0, ' = (', RW, ' - ', C, ') + ', D, ' * ',T],
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
createQ(P, D, S0, I, Z) :- createQEquations(P, D, T1),
                           append(['{'], [T1], T2),
                           append(T2, ['}.'], T),
                           nextFromPol(P, S0, _, A),
                           term_to_atom(A, A0),
                           createQHeader(S0, A0, I, C),
                           concatLists([[C], [', \n\t'], T], X2),
                           concat_atom(X2, '', Z).



createAllQ(P, D, S0, I, Z) :- findall(X,
                                        (
                                           t(A, S0, _, _), 
                                           changePolAction(P, S0, A, P0), 
                                           createQ(P0, D, S0, I, X)
                                        ), 
                                    Z2),
                              sort(Z2, Z3),
                              concat_atom(Z3, '\n', Z).



createAllQfromS(P, D, I, Z) :- findall(X, 
                                         (
                                            s(S0), 
                                            createAllQ(P, D, S0 ,I ,X)
                                         ), 
                                     Z2),
                               sort(Z2, Z3),
                               concat_atom(Z3, '\n', Z).



saveQ(P, D, I) :- createPolTitle(P, P3),
                  createAllQfromS(P, D, I, Z),
                  append([P3], [Z], Z2),
                  concat_atom(Z2, '\n', Z3),
                  saveFile('./q.txt', Z3),
                  !.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Ek Functions


/* monta condicoes de saida da resposta */
createEkCondition(S0, X) :- upcase_atom(S0, V0), 
                            Z = ['(S0 = ', S0, ', ', 'X = ', V0, ')'], 
                            concat_atom(Z, '', X).



createEkConditions(X) :- findall(Z, (s(S0), createEkCondition(S0, Z)), X1), 
                         concat_atom(X1, '; ', X2), 
                         X3 = ['(', X2, ')'], 
                         concat_atom(X3, '', X).


/* monta Ek */
createEkHeader(I, X) :- createEkConditions(Y), 
                        Z = ['ek(S0, ', I, ', X) :- ', Y],
                        concat_atom(Z, '', X).



/* monta parenteses Probabilidade */
createEkProbs(P, S0, X) :- findall(Z, 
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
createEkEquation(P, S0, D, Q) :- createEkProbs(P, S0, T), 
                                 nextFromPol(P, S0, S1, A), 
                                 c(A, S0, C), 
                                 r(S0, RW), 
                                 upcase_atom(S0, V0), 
                                 X = [V0, ' = (', RW, ' - ', C, ') + ', D, ' * ', T], 
                                 concat_atom(X, ' ', Q), !.



/* monta todas equacoes (para cada estado) */
createEkEquations(P, D, Z3) :- findall(X, (s(S0), createEkEquation(P, S0, D, X)), Z), 
                               sort(Z, Z2), 
                               concat_atom(Z2, ', \n\t', Z3).



createEk(P, D, I, Z) :- createEkEquations(P, D, T1),
                        append(['{'], [T1], T2),
                        append(T2, ['}, !.'], T),
                        createEkHeader(I, C),
                        concatLists([[C], [', \n\t'], T], X2),
                        concat_atom(X2, '', Z).



saveEk(P, D, I) :- createPolTitle(P, P3),
                   createEk(P, D, I, Z),
                   append([P3],[Z], Z2),
                   concat_atom(Z2, '\n', Z3),
                   saveFile('./ek.txt', Z3),
                   !.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Value Iteration Algoritm

valueIt(D, IMAX, P0) :- (pol(P),!),
                         valueIt(P, D, IMAX, P0).

valueIt(P, D, IMAX, P0) :- write('\n'),
                           write('**********************\n'),
                           write('Value Iteration # 0\n'),
                           write('**********************\n'),
                           saveP(P),
                           saveEk(P, D, 0),
                           valueIt2(D, 1, IMAX, P0).

valueIt2(D, I, I, P0) :- valueIt3(D, I, P0), !.

valueIt2(D, I, IMAX, P0) :- I \= IMAX,
                            valueIt3(D, I, _),
                            I2 is I + 1,
                            valueIt2(D, I2, IMAX, P0).

valueIt3(D, I, P0):- string_concat('\n**********************\nValue Iteration # ', I, X1), string_concat(X1,'\n**********************\n', X), write(X),
                     p(P),
                     saveQ(P, D, I),
                     changePolActions(P, P0),
                     saveP(P0),
                     saveEk(P0, D, I).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%valueIt(0.9, 10, P0).


% Step by Step - Value Iteration
% Define P
% P=[[s1, wait], [s2, wait], [s3, wait], [s4, wait], [s5, wait]]
% P=[[s1, wait], [s2, wait], [s3, wait], [s4, wait], [s5, wait]],saveP(P).
% p(P),saveEk(P,0.9,0).

% p(P),saveQ(P,0.9,1).
% p(P),changePolActions(P,P0),saveP(P0),saveEk(P0,0.9,1).

% p(P),saveQ(P,0.9,2).
% p(P),changePolActions(P,P0),saveP(P0),saveEk(P0,0.9,2).

% p(P),saveQ(P,0.9,3).
% p(P),changePolActions(P,P0),saveP(P0),saveEk(P0,0.9,3).

% p(P),saveQ(P,0.9,4).
% p(P),changePolActions(P,P0),saveP(P0),saveEk(P0,0.9,4).

% p(P),saveQ(P,0.9,5).
% p(P),changePolActions(P,P0),saveP(P0),saveEk(P0,0.9,5).
