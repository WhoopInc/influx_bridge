-module(influx_bridge_reader).
-behaviour(gen_server).

-export([
         init/1
        ,handle_call/3
        ,handle_cast/2
        ,handle_info/2
        ,code_change/3
        ,terminate/2
        ]).
-export([start_link/0]).

-record(state, {
         }).
-define(RECEIVE_COUNT, 10).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_) ->
    Port = stillir:get_config(influx_bridge, listen_port),
    {ok, _Socket} = gen_udp:open(Port, [binary, {active, ?RECEIVE_COUNT}]),
    {ok, #state{}}.

handle_call(a, a, a) ->
    a.

handle_cast(a, a) ->
    a.

handle_info({udp, _Sock, _Ip, _Port, Message}, State) ->
    wpool:cast(influx_bridge_writer, {udp, Message}, random_worker),
    {noreply, State};
handle_info({udp_passive, Socket}, State) ->
    lager:debug("re-activate socket"),
    inet:setopts(Socket, [{active, ?RECEIVE_COUNT}]),
    {noreply, State}.

code_change(a, a, a) ->
    a.

terminate(a, a) ->
    ok.
