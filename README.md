influx_bridge
=====

UDP input to InfluxDB is buggy (specifically, it responds to some types of bad data by silently quitting any UDP reads). There aren't any logs, so it's a pain to debug, too.

This is a quick application to accept UDP input, batch it up a little bit, and send it to InfluxDB via HTTP interface.

No input validation is attempted. InfluxDB's HTTP listener seems to handle bad inputs appropriately (and replies back with an error message), and influx_bridge logs these errors and continues to listen.

Build
-----
Requires Erlang 18 and Rebar 3 to build. To create a tarball to install on a remote machine (without Erlang or Rebar):

    $ rebar3 release tar

Run
----
After installing a release:

    $ INFLUX_URL=http://your.influx.db/write?db=yourDB LISTEN_PORT=8125 /path/to/influx_bridge/bin/influx_bridge start
