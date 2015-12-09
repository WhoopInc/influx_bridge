%%%-------------------------------------------------------------------
%% @doc influx_bridge public API
%% @end
%%%-------------------------------------------------------------------

-module('influx_bridge_app').

-behaviour(application).

%% Application callbacks
-export([start/2
        ,stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    ok = stillir:set_config(influx_bridge, [
                                            {influx_url, "INFLUX_URL", [required]}
                                           ,{listen_port, "LISTEN_PORT", [required, {transform, integer}]}
                                           ]),
    influx_bridge_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
