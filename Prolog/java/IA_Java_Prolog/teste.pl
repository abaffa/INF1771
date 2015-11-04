progenitor(sara,isaque).  
progenitor(abraao,isaque).
progenitor(abraao,ismael).
progenitor(isaque,esau).
progenitor(isaque,jaco).
progenitor(jaco,jose).

mulher(sara).
homem(abraao).
homem(isaque).
homem(ismael).
homem(esau).
homem(jaco).
homem(jose).

filho(Y,X) :- progenitor(X,Y).
mae(X,Y) :- progenitor(X,Y), mulher(X).
avo(X,Z) :- progenitor(X,Y), progenitor(Y,Z).
irmao(X,Y) :- progenitor(Z,X), progenitor(Z,Y).
ancestral(X,Z) :- progenitor(X,Z).
ancestral(X,Z) :- progenitor(X,Y), ancestral(Y,Z).
