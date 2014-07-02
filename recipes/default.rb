#
# Cookbook Name:: jenkins-chef-utils
# Recipe:: default
#
# Copyright (C) 2014 Spanlink Communications
#
# Apache 2.0
#

node.set['jenkins']['master']['install_method'] = 'war'
node.set['jenkins']['master']['version'] = '1.555'
node.set['jenkins']['master']['source'] = "#{node['jenkins']['master']['mirror']}/war/#{node['jenkins']['master']['version']}/jenkins.war"
# Dependency recipes
include_recipe 'java::default'
include_recipe 'jenkins::master'
include_recipe 'git::default'
include_recipe 'rvm::user'

# Jenkins plugins
%w{scm-api token-macro ant javadoc maven-plugin analysis-core violations dashboard-view warnings ruby-runtime rvm}.each do |plugin|
  jenkins_plugin plugin 
end

# Plugins that require special care. 
# Last one should restart jenkins service.
jenkins_plugin "git" do
  version '2.2.1'
end

jenkins_plugin "git-client" do
  version '1.9.1'
end

jenkins_plugin "config-file-provider" do
    version '2.7.4'
    notifies :restart, "service[jenkins]"
end
