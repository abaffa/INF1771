
%get Better Action to belief
%betterA(A,RW):- findall(X,(b2t(B), rw(B,A,RW),X=[A,RW]),Z),betterA2(Z,A,RW),!.
betterA(I,A,RW):- findall(X,(bi(I,B), rw(B,A,RW),X=[A,RW]),Z),betterA2(Z,A,RW),!.
betterA2([H|[]],A,RW):- H=[A,RW],!.
betterA2([H|T],A,RW):- H=[A1,RW1],betterA2(T,A2,RW2),((RW1>=RW2,A=A1,RW=RW1);(RW1<RW2,A=A2,RW=RW2)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%



/* monta condicoes de saida da resposta */

createEkCondition(BI, X) :- X1=['(BI = ', BI, ', ', 'V = EB_', BI, ')'], 
                           concat_atom(X1, '', X).

createEkConditions(X) :- findall(Z, (b(BI, _, _), createEkCondition(BI, Z)), X0), 
                         sort(X0, X1),
                         concat_atom(X1, '; ', X2), 
                         X3 = ['(', X2, ')'], 
                         concat_atom(X3, '', X).


%create Ek formula header
createEkHeader(X) :- createEkConditions(Y), 
                        Z = ['ek(BI, V) :- ', Y],
                        concat_atom(Z, '', X).


/* monta parenteses Probabilidade */
createEkProbs(BT, A, X) :- findall(X, 
                                     (
					o(O),
					bo(BT, O, A, P),
					nextBT(BT, A, O, BT2),
                                        findIBi(BT2, I),
                                        concat_atom(['EB_', I], EBF1),
                                        X=['+ (', P, '*', EBF1, ')']
                                     ), 
                                 X1), 
                           concatLists(X1, X2), 
                           concat_atom(X2, ' ', X3), 
                           X4 = ['(0 ', X3, ')'], 
                           concat_atom(X4, '', X), !.



createEkEquation(BT, BI, A, D, Q) :- createEkProbs(BT, A, T), 
                                     concat_atom(['EB_', BI], EBF2),
                                     rw(BT, A, RW), 
                                     X = [EBF2, ' = ', RW, ' + ', D, ' * ', T], 
                                     concat_atom(X, ' ', Q), !.


/* monta todas equacoes (para cada estado) */
createEkEquations(D, Z3) :- findall(X, 
                                          (
                                             b(BI, _, _),
                                             bi(BI, BT),
                                             betterA(BI,A,_),
                                             createEkEquation(BT, BI, A, D, X)
                                          ),
                                       Z), 
                            sort(Z, Z2), 
                            concat_atom(Z2, ', \n\t', Z3).



createEk(D, Z) :- createEkEquations(D, T1),
                  append(['{'], [T1], T2),
                  append(T2, ['}.'], T),                 %% append(T2, ['}, !.'], T),
                  createEkHeader(C),
                  concatLists([[C], [', \n\t'], T], X2),
                  concat_atom(X2, '', Z).



saveEk(D) :- createEk(D, Z),
             saveFile('./ek.txt', Z),
             !.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

%%%%%%%
%% initializeB.
%% determina melhor acao.
%% betterA(A,RW).
%% determina observacao.
%% IX= -1, maxBi(IMAX),I is IMAX+1,O=tigre_dir,(IX= -1,I2 is I-1;I2=IX),betterA(I2,A,_),bi(I2,B),nextBT(B,A,O,BT),(findIBi(BT,NEWIX),!;saveB(BT,I),!).
%% IX= -1, maxBi(IMAX),I is IMAX+1,O=tigre_esq,(IX= -1,I2 is I-1;I2=IX),betterA(I2,A,_),bi(I2,B),nextBT(B,A,O,BT),(findIBi(BT,NEWIX),!;saveB(BT,I),!).
%% e(A) :- rw(A,RW), findall


