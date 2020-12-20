%%%%%%%%%%%
%Knowledge
%%%%%%%%%%%


%s = set of states
s(s1). %s(at(r1,l1)). 
s(s2). %s(at(r1,l2)). 
s(s3). %s(at(r1,l3)). 
s(s4). %s(at(r1,l4)). 
s(s5). %s(at(r1,l5)). 



%a = set of actions
a(move(r1,l1,l2)).
a(move(r1,l2,l1)).
a(move(r1,l2,l3)).
a(move(r1,l3,l2)).
a(move(r1,l5,l2)).
a(move(r1,l4,l1)).
a(move(r1,l1,l4)).
a(move(r1,l3,l4)).
a(move(r1,l4,l3)).
a(move(r1,l4,l5)).
a(move(r1,l5,l4)).
a(wait).



%pa = matrix of transitions
%pa(Action,Initial State, Final State, Probability).
t(move(r1,l1,l2), s1, s2, 1).
t(move(r1,l2,l1), s2, s1, 1).
t(move(r1,l2,l3), s2, s3, 0.8).
t(move(r1,l2,l3), s2, s5, 0.2).
t(move(r1,l3,l2), s3, s2, 1).
t(move(r1,l5,l2), s5, s2, 1).
t(move(r1,l4,l1), s4, s1, 1).
t(move(r1,l1,l4), s1, s4, 0.5).
t(move(r1,l1,l4), s1, s1, 0.5).
t(move(r1,l3,l4), s3, s4, 1).
t(move(r1,l4,l3), s4, s3, 1).
t(move(r1,l4,l5), s4, s5, 1).
t(move(r1,l5,l4), s5, s4, 1).
t(wait, s1, s1, 1).
t(wait, s2, s2, 1).
t(wait, s3, s3, 1).
t(wait, s4, s4, 1).
t(wait, s5, s5, 1).



%r = set of rewards
%r(State, Reward)
r(s1, 0).
r(s2, 0).
r(s3, 0).
r(s4, 100).
r(s5, -100).



%cost = set of costs
%cost(Action,Actual State,Cost)
c(move(r1,l1,l2), s1, 100).
c(move(r1,l2,l1), s2, 100).
c(move(r1,l2,l3), s2, 1).
c(move(r1,l3,l2), s3, 1).
c(move(r1,l5,l2), s5, 1).
c(move(r1,l4,l1), s4, 1).
c(move(r1,l1,l4), s1, 1).
c(move(r1,l3,l4), s3, 100).
c(move(r1,l4,l3), s4, 100).
c(move(r1,l4,l5), s4, 100).
c(move(r1,l5,l4), s5, 100).
c(wait, s1, 0).
c(wait, s2, 0).
c(wait, s3, 0).
c(wait, s4, 0).
c(wait, s5, 100).
