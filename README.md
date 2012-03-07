Tunnels
=======

![image](http://i.imgur.com/5F9tJ.png)

Tunnels is a proxy to http from https.

You can run the [Pow](http://pow.cx/) over SSL!

Installation
------------

    $ gem install tunnels

Run
---

    $ sudo tunnels

If you are using rvm:

    $ rvmsudo tunnels

By default, proxy to 80 port from 443 port.

specify `http` port:

    $ sudo tunnels 4567

specify `http` port and `https` port:

    $ sudo tunnels 4567 443

Copyright
---------

Copyright (c) 2012 jugyo, released under the MIT license.