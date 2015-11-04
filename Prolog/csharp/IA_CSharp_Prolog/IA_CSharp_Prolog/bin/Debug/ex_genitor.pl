progenitor(sara,isaque).  
progenitor(abraão,isaque).
progenitor(abraão,ismael).
progenitor(isaque,esaú).
progenitor(isaque,jacó).
progenitor(jacó,josé).

mulher(sara).
homem(abraão).
homem(isaque).
homem(ismael).
homem(esaú).
homem(jacó).
homem(josé).


filho(Y,X) :- progenitor(X,Y).

mae(X,Y) :- progenitor(X,Y), mulher(X).
%pai(X,Y) :- progenitor(X,Y), homem(X).

avo(X,Z) :- progenitor(X,Y), progenitor(Y,Z).
%avó(X,Z) :- (mãe(X,Y),mãe(Y,Z)); (mãe(X,Y),pai(Y,Z)).
%avô(X,Z) :- (pai(X,Y),mãe(Y,Z)); (pai(X,Y),pai(Y,Z)).

irmao(X,Y) :- progenitor(Z,X), progenitor(Z,Y).

ancestral(X,Z) :- progenitor(X,Z).
ancestral(X,Z) :- progenitor(X,Y), ancestral(Y,Z).



tem_filho(X) :- progenitor(X,_).
alguém_tem_filho :- progenitor(_,_).

