%%%%%%%%%%%%%%%%%%
%%Value Iteration
%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%

bBkTk(Z):- findall(X, b(X,_,_), Y), sort(Y,YY), list2BkTk(YY,Z).

list2BkTk([H|T],X):- X=H; list2BkTk(T,X).

%savebBkTk:- findall(X, (b(I,_,_), X0 = ['bBkTk(',I,').'], concat_atom(X0, '', X)), Y), sort(Y,YY), concat_atom(YY, '\n', Y2), saveFile('./bbktk.txt', Y2).

%pp(P) :- findall(X,((a(A),!), o(O), b(I,_,_),X=[I, O, A]),Y), sort(Y,P).
pp(P) :- findall(X,((a(A),!), o(O), bBkTk(I),X=[I, O, A]),Y), sort(Y,P).


createS(S) :- findall(X, (o(O), bBkTk(Z), Y=['s(b', Z, '_', O, ').'], concat_atom(Y, '', X)), X0), sort(X0, X1), concat_atom(X1, '\n', S).
createA(A) :- findall(X, (a(A), Y=['a(', A, ').'], concat_atom(Y, '', X)), X0), sort(X0, X1), concat_atom(X1, '\n', A).
createC(C) :- findall(X, (a(A), o(O), bBkTk(Z), bi(Z, BT), rw(BT, A, RW), RW2 is RW * -1,  Y=['c(', A, ', b', Z, '_', O, ', ', RW2, ').'], concat_atom(Y, '', X)), X0), sort(X0, X1), concat_atom(X1, '\n', C).
createR(R) :- findall(X, (o(O), bBkTk(Z), Y=['r(b', Z, '_', O, ', 0).'], concat_atom(Y, '', X)), X0), sort(X0, X1), concat_atom(X1, '\n', R).
createT(T) :- findall(X, (bBkTk(BI0), o(O0), concat_atom(['b', BI0, '_', O0], '', S0), a(A), bi(BI0, BT0), nextBT(BT0, A, O, BT1), getBi(BT1, BI1), o(O1), concat_atom(['b', BI1, '_', O1], '', S1), criaProb(BT0, O0, A, P), Y=['t(', A, ', ', S0, ', ', S1, ', ', P, ').'], concat_atom(Y, '', X)), X0), sort(X0, X1), concat_atom(X1, '\n', T).

convertPomdp2Mdp :- createS(S), createA(A), createC(C), createR(R), createT(T), concat_atom([S, A, C, R, T],'\n', Z), saveFile('./pomdp_mdp_data.txt', Z).

countList([],0) :- !.
countList([H|T],I) :- countList(T,I2), I is I2 + 1.

criaProb(BT0, O0, A, P) :- findall(X, nextBT(BT0, A, O, X), Y), countList(Y,I), P is 1 / I.


%%%%

getBi(BT, BI1) :- ((findIBi(BT, BI1), !); (maxBi(IMAX), I is IMAX + 1, saveB(BT,I), findIBi(BT, BI1), !)).


t(A, BI0, O, BI1, _) :- bi(BI0, BT0), nextBT(BT0, A, O, BT1), getBi(BT1, BI1).

% a(A),  o(O),
testee :- testee(-1).
testee(I) :- writeln('##############################'), testee2(I2), write(I2),write('#'), writeln(I), I \= I2,  testee(I2).
testee2(I) :- teste,  maxBi(I).

teste :- findall(X, (teste(A,O), X=[A,O]), _).
%teste(A,O) :- a(A),  o(O), b(I,_,_), teste(A, O, I).
teste(A,O) :- a(A),  o(O), bBkTk(I), teste(A, O, I).
teste(A, O, BI0) :- t(A, BI0, O, BI1, _), write(A), write('-'),  write(O), write('-'), write(BI0), write('-'), write(BI1), nl, ((BI0 \= BI1, teste(A, O, BI1));(BI0 = BI1)).


%%nextFromPol(Policy, Initial State, Final State, Action)
nextFromPol([P|T], BI0, O, BI1, A) :- (P = [BI0|[O,A]], t(A, BI0, O, BI1, _)); 
                                 nextFromPol(T, BI0, O, BI1, A).

%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%


