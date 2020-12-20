%%%%%%%%%%%%%%%%%%%%%%
%POMDP based Planner
%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Belief Functions

%probabilidade de o novo estado ser S1, dado que a acao A foi executada.
ba(BT, S1, A, BA) :- findall(X, 
                               (
                                  pa(A, S0, S1, P,_),
                                  t2b(BT, S0, B),
                                  X is B * P
                               ),
                          BA0), 
                     sum(BA0, BA).



%probabilidade de a proxima observacao ser O, sendo que a acao A foi executada.
bo(BT, O, A, BO) :- findall(X, 
                              (
                                 po(A, S1, O, P),
                                 ba(BT, S1, A, BA),
                                 X is BA * P
                              ),
                         BO0), 
                    sum(BO0, BO).



%novo estado de crenca b' eh composto pelas probabilidade b'(S) (ou bao(S)):
bao(BT, A, O, S, P) :- po(A, S, O, PO),
                       ba(BT, S, A, BA),
                       bo(BT, O, A, BO),
                       P2 is ((PO * BA) / BO),
                       round(P2, 3, P),
                       !.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Other Functions


%rw(BT,A,RW)
rw([H|[]], A, RW) :- H = [S, B], 
                     r(A, S, RW1), 
                     RW is B * RW1.

rw([H|T], A, RW) :- rw(T, A, RW2),
                    H = [S, B],
                    r(A, S, RW1),
                    RW is (B * RW1) + RW2.



%Initial Belief to Belief Table
b2t(B) :- findall(X, 
                    (
                       b(S, P),
                       X=[S, P]
                    ),
                 Y),
          sort(Y,B).



%Belief Table to Belief b(S,P).
t2b([H|[]], S, P) :- H = [S, P], !.

t2b([H|T], S, P) :- H=[S,P]; 
                    t2b(T, S, P).



%Belief Table - bi(B_num, BT)
bi(I, BT) :- findall(X, 
                       (
                          call('b', I, S, P),
                          X = [S, P]
                       ), 
                   B1),
             sort(B1, BT).



%set of beliefs - all beliefs
allBi(BI) :- findall(X, b(X, _, _) ,Y),
             sort(Y, Z),
             allBi2(Z, BI0),
             sort(BI0, BI),
             !.

allBi2([H|[]], BI) :- bi(H, B),
                      BI = [[H, B]],
                      !.

allBi2([H|T], BI) :- allBi2(T, BI2),
                     bi(H, B),
                     BI3 = [[H, B]],
                     append(BI2, BI3, BI).



%verify if beliefs are equal
isEqualBelief([], []) :- !. 

isEqualBelief([HB0|TB0], [HB1|TB1]) :- HB0 = [SB0, PB0], 
                                       HB1 = [SB1, PB1],
                                       atom_chars(SB0, D0), atom_chars(SB1, D0),
                                       atom_chars(PB0, D1), atom_chars(PB1, D1),
                                       isEqualBelief(TB0, TB1).


%find a Belief state and return its number
findIBi(B, I) :- allBi(BI), 
                 findIBi2(BI, B, I),
                 !.

findIBi2([H|[]], B, I) :- H = [I0, B0],
                          isEqualBelief(B, B0),
                          I = I0, 
                          !.

findIBi2([H|T], B, I) :- T \= [],
                         (
                            (
                               H = [I0, B0],
                               isEqualBelief(B, B0),
                               I = I0,
                               !
                            );
                            (
                               findIBi2(T,B,I),
                               !
                            )
                         ).



%return max Belief state number
maxBi(I) :- findall(X, b(X, _, _) ,Y),
            sort(Y, Z),
            maxBi2(Z, I).

maxBi2([H|[]], H):- !.

maxBi2([H|T], I) :- maxBi2(T, I2),
                    (
                       (
                          H >= I2,
                          I = H
                       );
                       (
                          H < I2,
                          I = I2
                       )
                    ).

nextBT(BT0, A, O, BT1) :- findall(X,
                                    (
                                       s(S),
                                       bao(BT0, A, O, S, P), 
                                       X = [S, P]
                                    ), 
                               BT2),
                          sort(BT2,BT1).



%bi(0,BT),betterA(0,A,RW),saveNextB(BT,A).
%create next Belief states from actual belief running an action

saveNextB(BT, A) :- findall(X,
                              (
                                 o(O),
                                 nextBT(BT, A, O, X)
                              ),
                           Y),
                    sort(Y, Y2),
                    saveNextB2(Y2),
                    !.

saveNextB2([H|[]]) :- (
                         findIBi(H, _);
                         (
                            maxBi(IMAX),
                            I is IMAX + 1,
                            write(H),
                            saveB(H, I)
                         )
                      ),
                      !.

saveNextB2([H|T]) :- saveNextB2(T),
                     maxBi(IMAX),
                     I is IMAX + 1,
                     (
                        findIBi(H, _);
                        (
                           write(H),
                           saveB(H, I)
                        )
                     ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

%initialize Belief file - create B0 from initial belief state
initializeB :- b2t(BT),
               createB(BT, 0, C),
               saveFile('b.txt', C).



%create new Belief formula
createB(BT,I,C) :- findall(X,
                             (
                                t2b(BT, S, P),
                                Q = ['b(', I, ', ', S, ', ', P, ').'],
                                concat_atom(Q, '', X)
                             ),
                          Z),
                   append(Z, [''], Z2),
                   concat_atom(Z2, '\n', C).



%save Belief to file
saveB(BT, I) :- createB(BT, I, C),
                appendFile('b.txt', C).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

actualBeliefState([H|[]], B, P):- H = [B, P], !.
actualBeliefState([H|T], B, P) :- H = [B1,P1], actualBeliefState(T, B2, P2), ((P1 >= P2, B = B1, P = P1); (P1 < P2, B = B2, P = P2)).