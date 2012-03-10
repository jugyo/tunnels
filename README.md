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

If you are using rvm:

    $ rvmsudo tunnels

By default, proxy to 80 port from 443 port.

specify "http" port and "https" port:

    $ sudo tunnels 443 3000

or

    $ sudo tunnels 127.0.0.1:443 127.0.0.1:3000

Config File
-----------

When using the verbose format for specifying host and port, you may
append a third argument with the location of a configuration file

    $ sudo tunnels 443 80 my_config.yml

The format for the configuration file is simple:

    server:
      certificate_file: certs/server.crt
      private_key_file: certs/server.key
    client:
      verify: true
      certificate_ca_file: certs/server-ca.crt

All paths in the configuration file are relative to the file itself and
will be normalized by the config file reader.

**NOTE:** Due to a [lack of support][bug] for [RFC 5746][] support in
Safari, enabling peer verification will only work in Firefox, Chrome,
IE and Opera. Until Safari fixes this support, if you need client-side
certificates to work within Safari in your development environment you
are better looking for a different option.

[bug]: http://openradar.appspot.com/8696868
[RFC 5746]: http://tools.ietf.org/html/rfc5746

Copyright
---------

Copyright (c) 2012 jugyo, released under the MIT license.
