-module(bench).
-export([comp_list_and_fsm/1]).
-define(SEED, {14, 15, 600}).
-define(F_SIZE, 10000).
-define(G_SIZE, 100).
-include_lib("eunit/include/eunit.hrl").

comp_list_and_fsm_acc(0, _Fun1, _Fun2, Results) ->
    Results;
comp_list_and_fsm_acc(Iteration, Fun1, Fun2, Results) ->
    {T1, _V1} = timer:tc(Fun1),
    {T2, _V2} = timer:tc(Fun2),
    comp_list_and_fsm_acc(Iteration - 1, Fun1, Fun2, [{T1, T2} | Results]).

aggregate(F) ->
    receive
        stop ->
            lists:reverse(F);
        V ->
            aggregate([V | F])
    end.

comp_list_and_fsm(Iteration) ->
    random:seed(?SEED),
    F = [random:uniform() || _ <- lists:seq(1, ?F_SIZE)],
    G = [random:uniform() || _ <- lists:seq(1, ?G_SIZE)],
    Fun1 = fun() -> convolution:list(F, G) end,
    Fun2 = fun() ->
            Pid = convolution:gen_fsm(G),
            lists:map(fun(F1) -> Pid ! {self(), F1} end, F),
            Pid ! {self(), stop},
            aggregate([])
    end,
    comp_list_and_fsm_acc(Iteration, Fun1, Fun2, []).
