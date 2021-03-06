%%% -*- coding: utf-8; Mode: erlang; tab-width: 4; c-basic-offset: 4; indent-tabs-mode: nil -*-
%%% ex: set softtabstop=4 tabstop=4 shiftwidth=4 expandtab fileencoding=utf-8:
%%%
%%%------------------------------------------------------------------------
%%% @doc
%%% ==Math operations==
%%% @end
%%%
%%% BSD LICENSE
%%% 
%%% Copyright (c) 2009-2012, Michael Truog <mjtruog at gmail dot com>
%%% All rights reserved.
%%% 
%%% Redistribution and use in source and binary forms, with or without
%%% modification, are permitted provided that the following conditions are met:
%%% 
%%%     * Redistributions of source code must retain the above copyright
%%%       notice, this list of conditions and the following disclaimer.
%%%     * Redistributions in binary form must reproduce the above copyright
%%%       notice, this list of conditions and the following disclaimer in
%%%       the documentation and/or other materials provided with the
%%%       distribution.
%%%     * All advertising materials mentioning features or use of this
%%%       software must display the following acknowledgment:
%%%         This product includes software developed by Michael Truog
%%%     * The name of the author may not be used to endorse or promote
%%%       products derived from this software without specific prior
%%%       written permission
%%% 
%%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
%%% CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
%%% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
%%% OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%%% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
%%% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
%%% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
%%% BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%%% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%%% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
%%% WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
%%% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%%% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
%%% DAMAGE.
%%%
%%% @author Michael Truog <mjtruog [at] gmail (dot) com>
%%% @copyright 2009-2012 Michael Truog
%%% @version 0.2.0 {@date} {@time}
%%%------------------------------------------------------------------------

-module(cloudi_math).
-author('mjtruog [at] gmail (dot) com').

%% external interface
-export([sum/1, product/1,
         ceil/1, floor/1, round/2, frac/1,
         immediate_stddev/1,
         stddev/0, stddev/1, stddev/2, stddev/4]).

%%%------------------------------------------------------------------------
%%% External interface functions
%%%------------------------------------------------------------------------

%%-------------------------------------------------------------------------
%% @doc
%% ===Find the sum of a list of numbers.===
%% @end
%%-------------------------------------------------------------------------

-spec sum(list(number())) -> number().

sum(L) when is_list(L) ->
    lists:sum(L).

%%-------------------------------------------------------------------------
%% @doc
%% ===Find the product of a list of numbers.===
%% @end
%%-------------------------------------------------------------------------

-spec product(list(number())) -> number().

product(L) when is_list(L) ->
    lists:foldl(fun(X, Y) -> X * Y end, 1, L).

%%-------------------------------------------------------------------------
%% @doc
%% ===Provide a ceiling function.===
%% @end
%%-------------------------------------------------------------------------

-spec ceil(number()) -> integer().

ceil(X) ->
    erlang:round(X + 0.5).

%%-------------------------------------------------------------------------
%% @doc
%% ===Provide a floor function (for readability).===
%% @end
%%-------------------------------------------------------------------------

-spec floor(number()) -> integer().

floor(X) ->
    erlang:trunc(X).

%%-------------------------------------------------------------------------
%% @doc
%% ===Round to a decimal place.===
%% @end
%%-------------------------------------------------------------------------

-spec round(float(), integer()) -> float().

round(X, 1) ->
    erlang:round(X * 10) / 10.0;
round(X, 2) ->
    erlang:round(X * 100) / 100.0;
round(X, 3) ->
    erlang:round(X * 1000) / 1000.0;
round(X, 4) ->
    erlang:round(X * 10000) / 10000.0;
round(X, 5) ->
    erlang:round(X * 100000) / 100000.0;
round(X, 6) ->
    erlang:round(X * 1000000) / 1000000.0;
round(X, N) when is_integer(N) ->
    Scale = math:pow(10, N),
    erlang:round(X * Scale) / Scale.

%%-------------------------------------------------------------------------
%% @doc
%% ===Fractional part of a number.===
%% @end
%%-------------------------------------------------------------------------

-spec frac(number()) -> number().

frac(X) ->
    X - erlang:trunc(X).

%% Standard deviation algorithms better than:
%% StdDev = fun(L) -> M = lists:sum(L) / erlang:length(L), math:sqrt(lists:foldl(fun(V, S) -> (V - M) * (V - M) + S end, 0.0, L) / erlang:length(L)) end.

%%-------------------------------------------------------------------------
%% @doc
%% ===Calculate the standard deviation using the compensated-summation Two-pass algorithm===
%% Immediately calculate the standard deviation of the list.
%% @end
%%-------------------------------------------------------------------------

-spec immediate_stddev(list(number())) -> float().

immediate_stddev(L)
    when is_list(L) ->
    Count = erlang:length(L),
    immediate_stddev(L, 0.0, 0.0, lists:sum(L) / Count, Count).
immediate_stddev([], SumDiff, SumSqDiff, _, Count) ->
    math:sqrt((SumSqDiff - (SumDiff * SumDiff) / Count) / Count);
immediate_stddev([V | L], SumDiff, SumSqDiff, Mean, Count)
    when is_list(L) ->
    Difference = V - Mean,
    immediate_stddev(L,
                     Difference + SumDiff,
                     Difference * Difference + SumSqDiff,
                     Mean, Count).

%%-------------------------------------------------------------------------
%% @doc
%% ===Calculate the standard deviation using the On-line algorithm.===
%% B. P. Welford (1962). "Note on a method for calculating corrected sums of squares and products". Technometrics 4(3):419-420
%% @end
%%-------------------------------------------------------------------------

-spec stddev() ->
    {pos_integer(), float(), float()}.

stddev() ->
    stddev([]).

-spec stddev(list(number()) |
             {pos_integer(), float(), float()}) ->
    {pos_integer(), float(), float()} |
    {float(), float()}.

stddev(Input)
    when is_list(Input) ->
    stddev(Input, 1, 0.0, 0.0);
stddev({Count, Mean, Q}) ->
    {Mean, math:sqrt(Q / (Count - 1))}.

-spec stddev(list(number()), {pos_integer(), float(), float()}) ->
    {pos_integer(), float(), float()}.

stddev(Input, {Count, Mean, Q}) ->
    stddev(Input, Count, Mean, Q).

-spec stddev(list(number()), pos_integer(), float(), float()) ->
    {pos_integer(), float(), float()}.

stddev([], Count, Mean, Q) ->
    {Count, Mean, Q};
stddev([V | Input], Count, Mean, Q)
    when is_list(Input), is_integer(Count), is_float(Mean), is_float(Q) ->
    Difference = V - Mean,
    NewMean = Mean + Difference / Count,
    stddev(Input, Count + 1, NewMean, Q + Difference * (V - NewMean)).

