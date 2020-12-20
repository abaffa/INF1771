
:- consult('pomdp_planner.pl').

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
%% Desenha Tela

portaF1 :- write(' _______ ').
portaF2 :- write('||#####||').
portaF3 :- write('||#####||'). 
portaF4 :- write('||####O||').
portaF5 :- write('||#####||').
portaF6 :- write('||#####||').

portaA1 :- write(' _______ ').
portaA2 :- write('||     ||').
portaA3 :- write('||     ||'). 
portaA4 :- write('||     ||').
portaA5 :- write('||     ||').
portaA6 :- write('||     ||').

espacoEsquerdo :- write('    ').
espacoMeio :- write('        ').

desenha2portas :- espacoEsquerdo, portaF1, espacoMeio, portaF1, write('\n'),
                  espacoEsquerdo, portaF2, espacoMeio, portaF2, write('\n'),
                  espacoEsquerdo, portaF3, espacoMeio, portaF3, write('\n'),
                  espacoEsquerdo, portaF4, espacoMeio, portaF4, write('\n'),
                  espacoEsquerdo, portaF5, espacoMeio, portaF5, write('\n'),
                  espacoEsquerdo, portaF6, espacoMeio, portaF6, write('\n').

desenha2portasEsq :- espacoEsquerdo, portaA1, espacoMeio, portaF1, write('\n'),
                     espacoEsquerdo, portaA2, espacoMeio, portaF2, write('\n'),
                     espacoEsquerdo, portaA3, espacoMeio, portaF3, write('\n'),
                     espacoEsquerdo, portaA4, espacoMeio, portaF4, write('\n'),
                     espacoEsquerdo, portaA5, espacoMeio, portaF5, write('\n'),
                     espacoEsquerdo, portaA6, espacoMeio, portaF6, write('\n').

desenha2portasDir :- espacoEsquerdo, portaF1, espacoMeio, portaA1, write('\n'),
                     espacoEsquerdo, portaF2, espacoMeio, portaA2, write('\n'),
                     espacoEsquerdo, portaF3, espacoMeio, portaA3, write('\n'),
                     espacoEsquerdo, portaF4, espacoMeio, portaA4, write('\n'),
                     espacoEsquerdo, portaF5, espacoMeio, portaA5, write('\n'),
                     espacoEsquerdo, portaF6, espacoMeio, portaA6, write('\n').

desenhaAgente(BI) :- (bi(BI,BT), t2b(BT, tigre_esq, P), t2b(BT, tigre_dir, P),!), espacoEsquerdo, write('         '), write(' Agente '), write('         '), write('\n').
desenhaAgente(BI) :- (bi(BI,BT), t2b(BT, tigre_esq, P), P < 0.5 ,!),  espacoEsquerdo, write(' Agente  '), espacoMeio, write('         '), write('\n').
desenhaAgente(BI) :- (bi(BI,BT), t2b(BT, tigre_esq, P), P > 0.5 ,!),  espacoEsquerdo, write('         '), espacoMeio, write('  Agente '), write('\n').


desenhaTigre :- tigre(tigre_esq),
                espacoEsquerdo, write('  Tigre  '), espacoMeio, write(' Tesouro '), write('\n').

desenhaTigre :- tigre(tigre_dir),
                espacoEsquerdo, write(' Tesouro '), espacoMeio, write('  Tigre  '), write('\n').


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


titulo :- write('\n'),
          espacoEsquerdo, write('    Problema do Tigre\n'),
          espacoEsquerdo, write(' [Kaelbling et al. 1998]\n'),
          espacoEsquerdo, write('\n\n').

descricaoProblema :- titulo,
                     espacoEsquerdo, write('O Problema do Tigre consiste de um agente em frente a duas portas. Atrás de\n'),
                     espacoEsquerdo, write('uma porta, existe um tigre que irá atacá-lo, e, atrás da outra, existe um baú com uma grande\n'),
                     espacoEsquerdo, write('recompensa. Em vez de abrir uma porta, o agente pode apenas escutar para obter alguma\n'),
                     espacoEsquerdo, write('informação sobre a localizaçào do tigre. Mas escutar tem um preço e não é\n'),
                     espacoEsquerdo, write('muito confiável.\n').

detalhesProblema :- write('\n'), b2t(BT), 
                    write('    Belief Inicial - '), write(BT), write('\n'),
                    write('    Observação tem 85% de chance de estar correta'), write('\n\n'),
                    write('    Resultados de Ações: '), write('\n'),
                    write('       ouvir tem custo 1'), write('\n'),
                    write('       abrir porta errada tem custo -100'), write('\n'),
                    write('       abrir porta correta tem recompensa 10'), write('\n').


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


perguntaObservacao(O) :- write('\nObservação > '), readln(O0), atom_to_term(O0, O1, []), ((o(O1), O = O1);(not(o(O1)), observacoesValidas, perguntaObservacao(O))).
perguntaAcao(A) :- write('\nAção > '), readln(A0), atom_to_term(A0, A1, []), ((a(A1), A = A1);(not(a(A1)), acoesValidas, perguntaAcao(A))).

observacoesValidas :- findall(X, o(X), Y), write('\nObservações válidas:\n'), outputOptions(Y).
acoesValidas :- findall(X, a(X), Y), write('\nAções válidas:\n'), outputOptions(Y).

resultado(A) :- A = abrir_esq, tigre(tigre_esq),
                desenha2portasEsq,
                espacoEsquerdo, write('  Tigre  '), espacoMeio, write('         '), write('\n').

resultado(A) :- A = abrir_dir, tigre(tigre_dir),
                desenha2portasDir,
                espacoEsquerdo, write('         '), espacoMeio, write('  Tigre  '), write('\n').

resultado(A) :- A = abrir_esq, tigre(tigre_dir),
                desenha2portasEsq,
                espacoEsquerdo, write(' Tesouro '), espacoMeio, write('         '), write('\n').

resultado(A) :- A = abrir_dir, tigre(tigre_esq),
                desenha2portasDir,
                espacoEsquerdo, write('         '), espacoMeio, write(' Tesouro '), write('\n').


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


initializeTiger :- random(0, 2, X), ((X = 0, Y = 'tigre(tigre_esq).\n');(X = 1, Y = 'tigre(tigre_dir).\n')), saveFile('./tiger.txt', Y).

observa(X, N) :- random(0, 1.0, N), s(X), tigre(S), ((N =< 0.15, S \= X); (N > 0.15, S = X)),!.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


jogoAgente :- cls, descricaoProblema, detalhesProblema, write('\n... pressione enter para iniciar.'), get0(_), jogoLoopAgente, !.
jogoAgenteO :- cls, descricaoProblema, detalhesProblema, write('\n... pressione enter para iniciar.'), get0(_), jogoLoopAgenteO, !.
jogoUsuario :- cls, descricaoProblema, detalhesProblema, write('\n... pressione enter para iniciar.'), get0(_), jogoLoopUsuario, !.

jogoLoopAgente :- initializeB, initializeTiger, jogoLoopAgente(0).
jogoLoopAgente(B0) :- cls, determinaAcaoAgenteO(B0, O, A, BI1, BT), 
                titulo,
                write('Executou Ação - '), write(A), write('\n'),
                write('Observação   - '), write(O), write('\n'),
                write('Novo Belief  - '), write(BT), write('\n'),
                write('\n'),
                desenhaTigre,
                ((A \= ouvir, resultado(A), desenhaAgente(B0), write('\n... pressione enter para continuar.'), get0(_));(desenha2portas, desenhaAgente(B0), write('\n... pressione enter para continuar.'), get0(_), jogoLoopAgente(BI1))).


jogoLoopAgenteO :- initializeB, initializeTiger, jogoLoopAgenteO(0).
jogoLoopAgenteO(B0) :- cls,  
                titulo,
                write('\n'),
                desenhaTigre,
                desenha2portas, 
                desenhaAgente(B0),
                perguntaObservacao(O),
                determinaAcaoAgente(B0, O, A, BI1, BT), write('\n'),
                write('Executa Ação - '), write(A), write('\n'),
                write('Novo Belief  - '), write(BT), write('\n'),
                ((A \= ouvir, write('\n... pressione enter para continuar.'), get0(_), 
                  cls,  
                  titulo,
                  write('\n'),
                  desenhaTigre,
                  resultado(A), desenhaAgente(B0), 
                  write('\n... pressione enter para continuar.'), get0(_));
                 (write('\n... pressione enter para continuar.'), get0(_), jogoLoopAgenteO(BI1))).


jogoLoopUsuario :- initializeB, initializeTiger, jogoLoopUsuario(0).
jogoLoopUsuario(B0) :- cls,  
                titulo,
                observa(O, _),
                write('Observação - '), write(O), write('\n'),
                write('\n'),
%                desenhaTigre,
                desenha2portas, 
                desenhaAgente(B0),
                perguntaAcao(A),
                proximoBeliefUsuario(B0, O, A, BI1, BT), write('\n'),
                write('Executa Ação - '), write(A), write('\n'),
                write('Novo Belief  - '), write(BT), write('\n'),
                ((A \= ouvir, write('\n... pressione enter para continuar.'), get0(_), 
                  cls,  
                  titulo,
                  write('\n'),
%                  desenhaTigre,
                  resultado(A), desenhaAgente(B0), 
                  write('\n... pressione enter para continuar.'), get0(_));
                 (write('\n... pressione enter para continuar.'), get0(_), jogoLoopUsuario(BI1))).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

menu(N) :- cls, 
        titulo, nl,
        espacoEsquerdo, write('********'), nl,
        espacoEsquerdo, write('* Menu *'), nl,
        espacoEsquerdo, write('********'), nl, nl,
        espacoEsquerdo, write('(1) Decisões do Agente c/ observação automática'), nl, 
        espacoEsquerdo, write('(2) Decisões do Agente c/ observação fornecida pelo usuário'), nl, 
        espacoEsquerdo, write('(3) Decisões do Usuário'), nl, nl,
        espacoEsquerdo, write('(0) Sair'), nl, nl,
        write('\nEscolha > '), readln(N0), atom_to_term(N0, N1, []), (integer(N1),N1 >=0, N1 =< 3, N = N1, !);(menu(N)).

do_command(0) :- true.
do_command(1) :- jogoAgente, fail.
do_command(2) :- jogoAgenteO, fail.
do_command(3) :- jogoUsuario, fail.

inicio :-
   repeat,
   menu(N),
   do_command(N).

:- inicio, halt.