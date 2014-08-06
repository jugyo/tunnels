Tunnels
=======

![image](http://i.imgur.com/Ej5dz.png)

Tunnels is a proxy to http from https.

You can run the [Pow](http://pow.cx/) over SSL!

Installation
------------

    $ gem install tunnels

Run
---

    $ sudo tunnels
    
If you're on a Mac and wanna have tunnels run all the time, load it via launchctl from `/Library/LaunchAgents`:

    $ launchctl load jugyo.tunnels.plist
   
or use [LaunchRocket](https://github.com/jimbojsb/launchrocket), but don't forget to check the "As Root" option.

If you are using rvm:

    $ rvmsudo tunnels

By default, proxy to 80 port from 443 port.

specify "http" port and "https" port:

    $ sudo tunnels 443 3000

or

    $ sudo tunnels 127.0.0.1:443 127.0.0.1:3000

Copyright
---------

Copyright (c) 2012 jugyo, released under the MIT license.