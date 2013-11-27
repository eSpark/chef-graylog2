#
# Cookbook Name:: graylog2
# Recipe:: elasticsearch_approx_plugin
#
# This installs v 1.3.0 of the approx plugin, which enables distinct counts of a particular
# field for a histogram.
# More info here: https://github.com/pearson-enabling-technologies/elasticsearch-approx-plugin/tree/1.3.0
#
node.default[:elasticsearch][:path][:approx_plugin] = "/usr/local/elasticsearch/plugins/approx"

directory node[:elasticsearch][:path][:approx_plugin] do
  owner "elasticsearch"
  group "elasticsearch"
  mode 00755
  action :create
  recursive true
end

cookbook_file "elasticsearch-approx-plugin-1.3.0.zip" do
  path "/tmp/plugin_file.zip"
end

execute "unzip plugin" do
  not_if { File.exist?("#{node[:elasticsearch][:path][:approx_plugin]}/elasticsearch-approx-plugin-1.3.0.jar") }
  cwd node[:elasticsearch][:path][:approx_plugin]
  command "unzip -o /tmp/plugin_file.zip"
  notifies :restart, "service[elasticsearch]"
end
