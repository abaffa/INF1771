%%%%%%%%%%%%%%%%%%%
%%Initial Settings
%%%%%%%%%%%%%%%%%%%


:- use_module(library(clpr)).
:- style_check(-singleton).

:- consult('pomdp_generic.pl').
:- consult('pomdp_data.pl').
:- consult('pomdp_pol.pl').
:- consult('pomdp_belief.pl').


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Optimization Algorithms 
%%%%%%%%%%%%%%%%%%%%%%%%%%


%:- consult('pomdp_policyIteration.pl').
%:- consult('pomdp_valueIteration.pl').
%:- consult('pomdp_witness.pl').
:- consult('pomdp_algorithm.pl').





