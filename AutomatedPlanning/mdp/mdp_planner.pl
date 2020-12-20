%%%%%%%%%%%%%%%%%%%
%%Initial Settings
%%%%%%%%%%%%%%%%%%%


:- use_module(library(clpr)).
:- style_check(-singleton).

:- consult('mdp_generic.pl').
:- consult('mdp_data.pl').
:- consult('mdp_pol.pl').



%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Optimization Algorithms 
%%%%%%%%%%%%%%%%%%%%%%%%%%


:- consult('mdp_policyIteration.pl').
%:- consult('mdp_valueIteration.pl').



