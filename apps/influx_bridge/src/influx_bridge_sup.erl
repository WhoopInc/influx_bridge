%%%-------------------------------------------------------------------
%% @doc influx_bridge top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module('influx_bridge_sup').

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    WriterPoolSize = 10,
    Writer = #{
      id => writer_pool,
      start => {wpool, start_pool, [influx_bridge_writer, [
                                                           {workers, WriterPoolSize}
                                                          ,{worker, {influx_bridge_writer, []}}
                                                          ]]},
      restart => permanent,
      type => supervisor,
      modules => [writer]
     },
    Reader = #{
      id => reader,
      start => {influx_bridge_reader, start_link, []},
      restart => permanent,
      shutdown => brutal_kill,
      type => worker
     },
    Children = [Writer, Reader],
    SupFlags = #{ strategy => one_for_one, intensity => 5, period => 10},
    {ok, {SupFlags, Children}}.

%%====================================================================
%% Internal functions
%%====================================================================
