# Rumbrella

The rumbl app was copied from https://github.com/ArturT/phoenix-rumbl-app
Before copy we did clean up in this [commit](https://github.com/ArturT/phoenix-rumbl-app/commit/35c3394ae93a6dcf667a3da58605f3377be6ad98).


## Tips

Run tests for all apps:

    $ mix test

You can start rumbl app from main directory:

    $ mix phoenix.server

Run single test file for particular app from apps directory. The command must be run from main directory of umbrella app.

    # note there is missing prefix apps/rumbl/ in the test file path
    $ mix test test/channels/video_channel_test.exs

How to introspecting:

    $ cd apps/rumbl
    $ iex -S mix phoenix.server
    iex(0)> :observer.start
