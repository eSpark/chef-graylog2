#
# Cookbook Name:: graylog2
# Recipe:: web_interface
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

# Install required APT packages
package "build-essential"
if node.graylog2.email_package
    package node.graylog2.email_package
end

# Install rbenv
include_recipe "ruby_build"
include_recipe "rbenv::system"
rbenv_ruby   node.graylog2.ruby_version
rbenv_rehash "Rehash rbenv versions" do
  action :run
end
rbenv_global node.graylog2.ruby_version do
  action :create
end

# Install gem dependencies
%w{ bundler rake }.each do |g|
  rbenv_gem "#{g}"
end

# Create the release directory
directory "#{node[:graylog2][:basedir]}/rel" do
  mode 0755
  recursive true
end

directory "#{node[:graylog2][:web_interface][:log_path]}" do
  mode 0775
  recursive true
end

# Download the desired version of Graylog2 web interface from GitHub
remote_file "download_web_interface" do
  path "#{node[:graylog2][:basedir]}/rel/graylog2-web-interface-#{node[:graylog2][:web_interface][:version]}.tar.gz"
  source "https://github.com/Graylog2/graylog2-web-interface/archive/#{node[:graylog2][:web_interface][:version]}.tar.gz"
  action :create_if_missing
end

# Unpack the desired version of Graylog2 web interface
execute "tar zxf graylog2-web-interface-#{node[:graylog2][:web_interface][:version]}.tar.gz" do
  cwd "#{node[:graylog2][:basedir]}/rel"
  creates "#{node[:graylog2][:basedir]}/rel/graylog2-web-interface-#{node[:graylog2][:web_interface][:version]}/build_date"
  action :nothing
  subscribes :run, resources(:remote_file => "download_web_interface"), :immediately
end

# Link to the desired Graylog2 web interface version
link "#{node[:graylog2][:basedir]}/web" do
  to "#{node[:graylog2][:basedir]}/rel/graylog2-web-interface-#{node[:graylog2][:web_interface][:version]}"
end

# Perform bundle install on the newly-installed Graylog2 web interface version
bash "bundle install" do
  cwd "#{node[:graylog2][:basedir]}/web"
  environment "PATH" => ENV["PATH"] + ":/usr/local/rbenv/bin", "RBENV_ROOT" => "/usr/local/rbenv"
  code "echo `env` && source ~/.bashrc && echo `env` && /usr/local/rbenv/bin/rbenv local #{node[:graylog2][:ruby_version]} && source /etc/profile.d/rbenv.sh && bundle install --deployment --binstubs"
  subscribes :run, resources(:link => "#{node[:graylog2][:basedir]}/web"), :immediately
end

external_hostname = node[:graylog2][:external_hostname]     ? node[:graylog2][:external_hostname] :
    (node.has_key?('ec2') and node.ec2.has_key?('public_hostname')) ? node[:ec2][:public_hostname] :
    (node.has_key?('ec2') and node.ec2.has_key?('public_ipv4'))     ? node[:ec2][:public_ipv4] :
    node.has_key?('fqdn')                                           ? node.fqdn :
    "localhost"

# Create general.yml
template "#{node.graylog2.basedir}/web/config/general.yml" do
  owner "nobody"
  group "nogroup"
  mode 0644
  variables( :external_hostname => external_hostname )
end

# Create config files
%w{ indexer ldap mongoid }.each do |yml_file|
  template "#{node[:graylog2][:basedir]}/web/config/#{yml_file}.yml" do
    owner "nobody"
    group "nogroup"
    mode 0644
  end
end

# set up the secret - this should go to an attribute later
template "#{node[:graylog2][:basedir]}/web/config/initializers/secret_token.rb" do
  owner "nobody"
  group "nogroup"
  mode 0644
end

# Chown the Graylog2 directory to nobody/nogroup to allow web servers to serve it
execute "sudo chown -R nobody:nogroup graylog2-web-interface-#{node[:graylog2][:web_interface][:version]}" do
  cwd "#{node[:graylog2][:basedir]}/rel"
  not_if do
    File.stat("#{node[:graylog2][:basedir]}/rel/graylog2-web-interface-#{node[:graylog2][:web_interface][:version]}").uid == 65534
  end
  action :nothing
  subscribes :run, resources(:bash => "bundle install"), :immediately
end

# Stream message rake tasks
cron "Graylog2 send stream alarms" do
  minute node[:graylog2][:stream_alarms_cron_minute]
  action node[:graylog2][:send_stream_alarms] ? :create : :delete
  command "cd #{node[:graylog2][:basedir]}/web && RAILS_ENV=production bundle exec rake streamalarms:send"
end

cron "Graylog2 send stream subscriptions" do
  minute node[:graylog2][:stream_subscriptions_cron_minute]
  action node[:graylog2][:send_stream_subscriptions] ? :create : :delete
  command "cd #{node[:graylog2][:basedir]}/web && RAILS_ENV=production bundle exec rake subscriptions:send"
end