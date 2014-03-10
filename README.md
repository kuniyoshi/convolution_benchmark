RESULT
======

``` erlang
  39> Res = bench:comp_list_and_fsm(10).
  [{190928,216920},
   {207205,246463},
   {188907,192465},
   {190693,216284},
   {182016,265950},
   {203734,220434},
   {197605,273628},
   {191773,211928},
   {198077,265129},
   {241899,210406}]
  40> lists:sum([Fun1 || {Fun1, _} <- Res]) / length(Res).
  199283.7
  41> lists:sum([Fun2 || {_, Fun2} <- Res]) / length(Res).
  231960.7
  42>
```

ENVIRONMENT
===========

- MacBook Air
- OS X 10.9.2
- 1.7 GHz Intel Core i7
- 8 GB 1600 MHz DDR3
- Erlang R16B02 (erts-5.10.3) [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false]
