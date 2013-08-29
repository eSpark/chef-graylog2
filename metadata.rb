name              "graylog2"
maintainer        "Phil Sturgeon"
maintainer_email  "email@philsturgeon.co.uk"
license           "Apache 2.0"
description       "Installs and configures Graylog2"
version           "0.1.0"
recipe            "graylog2", "Installs and configures Graylog2"

# Only supporting Ubuntu 10.x and up
supports "ubuntu"

# OpsCode cookbook dependencies
depends "apt"     # http://community.opscode.com/cookbooks/apt
depends "rbenv"   # https://github.com/fnichol/chef-rbenv
depends "ruby_build" # http://community.opscode.com/cookbooks/ruby_build
depends "apache2" # http://community.opscode.com/cookbooks/apache2
depends "apache2" # http://community.opscode.com/cookbooks/apache2
depends "elasticsearch"
depends "mongodb" # http://community.opscode.com/cookbooks/mongodb