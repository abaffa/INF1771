%%%%%%%%%%%%%%%%%%%%%%
%Knowledge
%%%%%%%%%%%%%%%%%%%%%%

%s = set of states
s(tigre_esq).
s(tigre_dir).

%a = set of actions
a(ouvir).
a(abrir_esq).
a(abrir_dir).

%r = set of rewards
%r(State, Reward)
%r(listen,-1).
%r(tigre_esq,-100).
%r(tigre_dir,30).

%r(A,S,R) problema do tigre
r(abrir_esq,tigre_esq,-100).
r(abrir_dir,tigre_dir,-100).

r(abrir_esq,tigre_dir,10).
r(abrir_dir,tigre_esq,10).

r(ouvir,tigre_esq,-1).
r(ouvir,tigre_dir,-1).


%pa = matrix of transitions
%pa(A,S0,S1,P,C).

pa(abrir_esq,tigre_esq,tigre_esq,1.0,0).
%pa(abrir_dir,tigre_esq,tigre_dir,0.0,0).

%pa(abrir_esq,tigre_dir,tigre_esq,0.0,0).
pa(abrir_dir,tigre_dir,tigre_dir,1.0,0).

%pa(abrir_esq,tigre_esq,tigre_dir,0.0,0).
pa(abrir_esq,tigre_dir,tigre_dir,1.0,0).

pa(abrir_dir,tigre_esq,tigre_esq,1.0,0).
%pa(abrir_dir,tigre_dir,tigre_esq,0.0,0).

pa(ouvir,tigre_esq,tigre_esq,1,0).
%pa(ouvir,tigre_esq,tigre_dir,0,0).
%pa(ouvir,tigre_dir,tigre_esq,0,0).
pa(ouvir,tigre_dir,tigre_dir,1,0).


%o = set of observations
o(tigre_esq).
o(tigre_dir).

%Probabilidade O tigre esta em tigre_esq
%po(A,S,O,P).
po(ouvir,tigre_esq,tigre_esq,0.85).
po(ouvir,tigre_esq,tigre_dir,0.15).
po(ouvir,tigre_dir,tigre_esq,0.15).
po(ouvir,tigre_dir,tigre_dir,0.85).

po(abrir_esq,tigre_esq,tigre_esq,1.0).
%po(abrir_esq,tigre_esq,tigre_dir,0.0).
%po(abrir_esq,tigre_dir,tigre_esq,0.0).
po(abrir_esq,tigre_dir,tigre_dir,1.0).

%po(abrir_dir,tigre_esq,tigre_esq,0.0).
po(abrir_dir,tigre_esq,tigre_dir,1.0).
%po(abrir_dir,tigre_dir,tigre_esq,0.0).
po(abrir_dir,tigre_dir,tigre_dir,1.0).

%b = set of beliefs
%initial belief state
b(tigre_esq,0.5).
b(tigre_dir,0.5).
