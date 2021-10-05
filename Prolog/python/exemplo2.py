import sys
from pyswip import Prolog, Functor, Variable, Query

prolog = Prolog()
prolog.consult('./teste.pl')

ancestral = Functor("ancestral", 1)
x = Variable()
ancestral_query = Query(ancestral(x,'josé'))
ancestral_query.nextSolution()
print()
print(list(x.get_value())) 
ancestral_query.closeQuery()

ancestral = Functor("ancestral", 1)
x = Variable()
ancestral_query = Query(ancestral(x,'josé'))
ancestral_query.nextSolution()
valor_x = x.get_value()
print()
print(valor_x) # 
ancestral_query.closeQuery()
