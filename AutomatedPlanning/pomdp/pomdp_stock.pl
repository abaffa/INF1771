%%%%%%%%%%%%%%%%%%%
%%Initial Settings
%%%%%%%%%%%%%%%%%%%


:- use_module(library(clpr)).
:- style_check(-singleton).

:- consult('pomdp_generic.pl').
:- consult('pomdp_pol.pl').
:- consult('pomdp_belief.pl').


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Optimization Algorithms 
%%%%%%%%%%%%%%%%%%%%%%%%%%


:- consult('pomdp_algorithm.pl').



%%%%%%%%%%%%%%%%%%%%%%
%Knowledge
%%%%%%%%%%%%%%%%%%%%%%


%s = set of states
s(bear).
s(even).
s(bull).

%a = set of actions
a(manter).

%r = set of rewards
%r(A,S,R) problema do tigre
r(manter, bear, -10).
r(manter, bull, 10).
r(manter, even, 0).


%pa = matrix of transitions
%pa(A,S0,S1,P,C).

pa(manter, bear, bear, 0.3, 0).
pa(manter, bear, bull, 0.5, 0).
pa(manter, bear, even, 0.2, 0).

pa(manter, bull, bear, 0.2, 0).
pa(manter, bull, bull, 0.6, 0).
pa(manter, bull, even, 0.2, 0).

pa(manter, even, bear, 0.1, 0).
pa(manter, even, bull, 0.4, 0).
pa(manter, even, even, 0.5, 0).

%o = set of observations
o(up).
o(down).
o(unchanged).

%Probabilidade O tigre esta em tigre_esq
%po(A,S,O,P).
po(manter, bear, up, 0.1).
po(manter, bear, down, 0.6).
po(manter, bear, unchanged, 0.3).

po(manter, bull, up, 0.7).
po(manter, bull, down, 0.1).
po(manter, bull, unchanged, 0.2).

po(manter, even, up, 0.3).
po(manter, even, down, 0.3).
po(manter, even, unchanged, 0.4).

%b = set of beliefs
%initial belief state
b(bear, 0).
b(bull, 0).
b(even, 1).





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
/* apaga tela */
cls :-  put(27), put("["), put("2"), put("J").

readln(Z) :- get0(C),readln1(C,Z).
readln1(13,[]) :- get0(10),!. 
readln1(13,[]) :- !. 
readln1(10,[]) :- !. 
readln1(H, [H|T]):-get0(C), readln1(C,T).

outputOptions([H|[]]) :- write('   '), write(H), 
                         nl, 
                         !.

outputOptions([H|T]) :- write('   '), write(H), 
                        nl, 
                        outputOptions(T).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

perguntaObservacao(O) :- write('\nObservação > '), readln(O0), atom_to_term(O0, O1, []), ((o(O1), O = O1);(not(o(O1)), observacoesValidas, perguntaObservacao(O))).
observacoesValidas :- findall(X, o(X), Y), write('\nObservações válidas:\n'), outputOptions(Y).


jogoStock :- jogoLoopStock, !.
jogoLoopStock :- initializeB, jogoLoopStock(0).
jogoLoopStock(B0) :-  determinaAcaoAgenteO(B0, O, A, BI1, BT), 
		actualBeliefState(BT, BS, _),
                write('Executou Ação - '), write(A), write('\n'),
                write('Observação   - '), write(O), write('\n'),
                write('Novo Belief  - '), write(BT), write('\n'),
                write('Belief State - '), write(BS), write('\n'),
                write('\n'),
                write('\n... pressione enter para continuar.'), get0(_), jogoLoopStock(BI1).



jogoStockO :- jogoLoopStockO, !.
jogoLoopStockO :- initializeB, jogoLoopStockO(0).
jogoLoopStockO(B0) :-   
                write('\n'),
                perguntaObservacao(O),
                determinaAcaoAgente(B0, O, A, BI1, BT), write('\n'),
		actualBeliefState(BT, BS, _),
                write('Executa Ação - '), write(A), write('\n'),
                write('Novo Belief  - '), write(BT), write('\n'),
                write('Belief State - '), write(BS), write('\n'),

                write('\n... pressione enter para continuar.'), get0(_), jogoLoopStockO(BI1).



observa(X, N) :- random(0, 1.0, N), ((N =< 0.30, X = down); (N >= 0.70, X = up); (N > 0.30, N < 0.70, X = unchanged)),!.


determinaAcaoAgenteO(BI0, O, A, BI1, BT) :- observa(O, _), 
                                            determinaAcaoAgente(BI0, O, A, BI1, BT).

determinaAcaoAgente(BI0, O, A, BI1, BT) :- I2 = BI0, 
                                 maxBi(IMAX),
                                 I is IMAX + 1,
                                 betterA(I2, A, _),
                                 bi(I2, B),
                                 nextBT(B, A, O, BT),
                                 (
                                    findIBi(BT, BI1),
                                    !;
                                    saveB(BT,I),
                                    findIBi(BT, BI1),
                                    !
                                 ).


proximoBeliefUsuario(BI0, O, A, BI1, BT) :- I2 = BI0, 
                                 maxBi(IMAX),
                                 I is IMAX + 1,
                                 bi(I2, B),
                                 nextBT(B, A, O, BT),
                                 (
                                    findIBi(BT, BI1),
                                    !;
                                    saveB(BT,I),
                                    findIBi(BT, BI1),
                                    !
                                 ).



saveLastBI(BI) :- X = ['lastBI(',BI,').'], concat_atom(X,'',Y),  saveFile('./lastStockBI.txt', Y).


pregao(O, BT) :- lastBI(BI0), determinaAcaoAgente(BI0, O, manter, BI1, BT), saveLastBI(BI1).
%% initializeB, saveLastBI(0), saveFile('./results.txt',  '%\n'),!.
%% O = unchanged, pregao(O, BT), actualBeliefState(BT, BS, _),  X = ['%',BS, '\n'], concat_atom(X,'',Y), appendFile('./results.txt',  Y),!.
