#
# Cookbook Name:: graylog2
# Recipe:: unicorn
#
# Copyright 2010, Medidata Solutions Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Install Graylog2 web interface
include_recipe "graylog2::web_interface"

# Install gem dependencies
# graylog2 depends on rack ~> 1.4.1, whereas the newest version is 1.5.2
# so we have to use the right version of rack
rbenv_gem "rack" do
  version "1.4.5"
end
rbenv_gem "unicorn"

# Create general.yml
template "#{node[:graylog2][:basedir]}/web/config/unicorn.rb" do
  owner "nobody"
  group "nogroup"
  mode 0644
end

directory "#{node[:graylog2][:unicorn][:pid_path]}" do
  mode 0666
  recursive true
  owner "nobody"
end

# set unicorn to start on boot
rails_root = "#{node[:graylog2][:basedir]}/web"
template "/etc/init.d/graylog2_unicorn" do
  source "graylog2_unicorn.init.erb"
  mode 0755
  variables({
    rails_root: rails_root,
    pid_path: node[:graylog2][:unicorn][:pid_path],
    unicorn_port: node.graylog2.web_interface.listen_port
  })
end

service "graylog2_unicorn" do
  action :start
end

