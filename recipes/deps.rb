#
# Cookbook Name:: jenkins_utils
# Recipe:: deps
#
# This recipe adds the required dependencies to use the LWRPs provided in this 
# cookbook to a Jenkins CI server. Include it in the run list of your Jenkins 
# nodes.
#
# Author:: David Schlenk <david.schlenk@spanlink.com>
# Copyright (C) 2014 Spanlink Communications
#
# Apache 2.0
#

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
