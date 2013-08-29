Description
===========

This is a fork of the official Graylog2 chef repo, which makes several changes:

* Bump the graylog2 web version to 0.12.0, the server to 0.13.0-rc1
  * Points to the releases on Github
* Use the official elasticsearch recipe, to take advantage of ebs/aws/other
  features
* Incorporate Unicorn as a server, adapting work found in one of the other
  graylog2 repos and providing a few more config options
* Use fnichol's rbenv recipe, which seems to work better
* provide a template for the Rails secret_token, which is now required
  (attribute default[:graylog2][:secret_token])
* Start work on sharing log directories across deployments


Original Readme
===============

Installs and configures a Graylog2 server on Ubuntu systems (10.04 and up at present).

This is a Chef re-engineering of the [Sean Porter][seanp] Linode [StackScript for graylog2][stackscript].

Originally developed by [Jacob Zimmerman][jbz], and taken over by [Phil Sturgeon][phil] at v0.1.0.

Recipes
=======

default
-------

Downloads, installs, configures and starts the java graylog2-server.  Does *not* install 
the web interface. Uses resources from the Opscode [apt cookbook][apt] to add a repo from which
it pulls MongoDB.

web_interface
-------------

First calls `graylog2::default` to install the server.  Then downloads, installs, and configures 
the Rails-based Graylog2 [web interface][web].  Also installs [MongoDB][mongo] and [ElasticSearch][esearch]
to support it.

apache2
-------

First calls `graylog2::web_interface` to ensure that both the server and web interface are available.  Then
calls the Opscode [apache2 cookbook][apache2] to install Apache before (itself) installing the
mod_passenger module via apt, and finally calling `apache_site` to configure Apache to serve the
web interface.


Usage
=====

This cookbook can be called via any of its three recipes.  To get a fully working graylog2 server, call
`graylog::apache2` - it will set up the full stack, with apache2 installed to serve the Rails app.  If
you use another webserver, you can call `graylog2:web_interface`, which will install the base server 
and the web interface Rails app, but not configure a webserver to serve it.

Note that this cookbook makes lots of assumptions about defaults, and does things like install a local
mongodb server with no root password (doh).  Do be sure to tweak this for your comfort and security
before using it in production.

Also note - this cookbook does *not* switch off any local logging system.  That means that if you are
trying to get Graylog2 to 'catch' syslog messages, you may have to disable your local rsyslog or 
syslog-ng as they may have already snabbled up port 514.  The cookbook *does* sudo-start Graylog2, so 
it should be able to bind udp/514 at startup.  Stop/Start/restart Graylog2 using the installed init.d
script (/etc/init.d/graylog2 stop|start|restart).  TODO: convert to an upstart job.

License and Author
==================

Author:: J.B. Zimmerman (<jzimmerman@mdsol.com>)

Copyright 2011 Medidata Solutions, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

  [apt]: http://community.opscode.com/cookbooks/apt
  [apache2]: http://community.opscode.com/cookbooks/apache2
  [mongo]: http://www.mongodb.org/
  [esearch]: http://www.elasticsearch.org/
  [jbz]: http://community.opscode.com/users/jbz
  [phil]: http://community.opscode.com/users/philsturgeon
  [seanp]: http://twitter.com/portertech
  [stackscript]: https://www.linode.com/stackscripts/view/?StackScriptID=1970
  [web]: https://github.com/Graylog2/graylog2-web-interface