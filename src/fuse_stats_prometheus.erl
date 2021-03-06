%%% @doc fuse_stats_prometheus - use prometheus counters for fuse stats.
%%% Assumes that you have already arranged to start folsom
-module(fuse_stats_prometheus).
-behaviour(fuse_stats_plugin).
-export([init/1, increment/2]).

-define(RESPONSES_COUNTER_NAME(NameBin), <<NameBin/binary, "_responses_total">>).

-define(MELTS_COUNTER_NAME(NameBin), <<NameBin/binary, "_melts_total">>).

%% @doc Initialize prometheus counters for  `Name'.
%% Exports the following metrics:
%% `Name_responses_total[type]'
%% `Name_melts_total'
%% Uses Default Registry.
-spec init(Name :: atom()) -> ok.
init(Name) ->
  NameBin = atom_to_binary(Name, utf8),

  prometheus_counter:new([{name, ?RESPONSES_COUNTER_NAME(NameBin)},
                          {help, <<NameBin/binary, " fuse responses counter">>},
                          {labels, [type]}]),
  prometheus_counter:new([{name, ?MELTS_COUNTER_NAME(NameBin)},
                          {help, <<NameBin/binary, " fuse melts counter">>}]),
  ok.

%% @doc Increment `Name's `Counter'.
-spec increment(Name :: atom(), Counter :: ok | blown | melt) -> ok.
increment(Name, Counter) ->
  NameBin = atom_to_binary(Name, utf8),
  case Counter of
    ok ->
      prometheus_counter:inc(?RESPONSES_COUNTER_NAME(NameBin), [ok]);
    blown ->
      prometheus_counter:inc(?RESPONSES_COUNTER_NAME(NameBin), [blown]);
    melt ->
      prometheus_counter:inc(?MELTS_COUNTER_NAME(NameBin))
  end,
  ok.
