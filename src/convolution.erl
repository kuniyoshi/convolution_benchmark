-module(convolution).
-export([list/2, gen_fsm/1, fsm/2, calc_fsm/2]).
-include_lib("eunit/include/eunit.hrl").

list_acc(F, G, Acc) when length(F) =:= length(G) + length(G) - 1 ->
    tl(lists:reverse(Acc));
list_acc(F, G, Acc) ->
    V = lists:sum(lists:map(fun({A, B}) -> A * B end,
                            lists:zip(lists:sublist(F, length(G)), G))),
    list_acc(tl(F), G, [V | Acc]).

list(F, G) ->
    F2 = lists:append([lists:duplicate(length(G), 0),
                       F,
                       lists:duplicate(length(G), 0)]),
    list_acc(F2, lists:reverse(G), []).

fsm(G, PastF) ->
    receive
        {From, stop} ->
            From ! stop;
        {From, F} ->
            {PastF2, _} = lists:split(length(PastF) - 1, PastF),
            PastF3 = [F | PastF2],
            V = lists:sum(lists:map(fun({Z1, Z2}) -> Z1 * Z2 end, lists:zip(G, PastF3))),
            From ! V,
            fsm(G, PastF3)
    end.

gen_fsm(G) ->
    Pid = spawn(?MODULE,
                fsm,
                [G, lists:duplicate(length(G), 0)]),
    Pid.

aggregate(Convoluted) ->
    receive
        stop ->
            lists:reverse(Convoluted);
        V ->
            aggregate([V | Convoluted])
    end.

calc_fsm(F, G) ->
    Pid = gen_fsm(G),
    [Pid ! {self(), Fx} || Fx <- F],
    Pid ! {self(), stop},
    C = aggregate([]),
    C.
