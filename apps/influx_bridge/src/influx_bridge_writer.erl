-module(influx_bridge_writer).
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
          timer = undefined,
          buffer = []
         }).
-define(MAX_BUFFER, 10).
-define(FLUSH_DELAY_MS, 1000).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init(_) ->
    {ok, #state{}}.

handle_call(a, a, a) ->
    a.

handle_cast({udp, Data}, State = #state{buffer=Buf, timer=Timer}) ->
    lager:debug("New data coming in"),
    timer:cancel(Timer),
    {Buf1,Timer1} = maybe_flush(Data, Buf),
    {noreply, State#state{buffer=Buf1, timer=Timer1}};
handle_cast(flush, State = #state{buffer=Buffer}) ->
    lager:debug("Buffer flush requested"),
    flush(Buffer),
    {noreply, State#state{buffer=[], timer=undefined}}.

handle_info(a, a) ->
    a.

code_change(a, a, a) ->
    a.

terminate(a, a) ->
    a.

maybe_flush(Data, Buf) when length(Buf) >= ?MAX_BUFFER ->
    lager:debug("Buffer full"),
    flush([Data|Buf]),
    {[], undefined};
maybe_flush(Data, Buf) ->
    lager:debug("Buffering data"),
    {ok, Timer} = timer:apply_after(?FLUSH_DELAY_MS, gen_server, cast, [self(), flush]),
    {[Data|Buf], Timer}.

flush(Buffer) ->
    Url = stillir:get_config(influx_bridge, influx_url),
    Headers = [{<<"Content-Type">>, <<"text/plain">>}],
    Body = lists:foldr(fun (El, []) -> [El]; (El, Agg) -> [El,10|Agg] end, [], Buffer),
    lager:debug("Flushing ~p to ~p", [Body, Url]),
    case ibrowse:send_req(Url, Headers, post, Body, []) of
        {ok, "204", _, _} ->
            lager:debug("Successful write"),
            ok;
        {ok, Status, _, ResponseBody} ->
            lager:warning("code=~p body=~p unexpected response code", [Status, ResponseBody]);
        Other ->
            lager:error("Unexpected response: ~p", [Other])
    end.
