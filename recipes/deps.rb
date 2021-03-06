# encoding: UTF-8
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

# Update 404s to avoid 404s when installing packages
if platform_family?('debian')
  node.set['apt']['compile_time_update'] = true
  include_recipe 'apt::default'
  %w{libxml2-utils bash gawk sed grep debianutils coreutils tar curl gzip bzip2}
  .each do |pkg|
    package pkg
  end
end

include_recipe 'git::default'
node.set['rvm']['user_installs'] = [
  { 'user' => 'jenkins',
    'home' => '/var/lib/jenkins',
    'default_ruby' => 'ruby-2.0',
    'rubies' => ['1.9.3', '2.0', '2.1']
  }
]
include_recipe 'rvm::user'

# required to make the tests happy. You'll want to define this properly.
service 'jenkins'
# Jenkins plugins
%w{scm-api token-macro ant javadoc maven-plugin analysis-core}.each do |plugin|
  jenkins_plugin plugin
end

%w{violations dashboard-view warnings rvm}.each do |plugin|
  jenkins_plugin plugin
end

# Plugins that require special care.
# Last one should restart jenkins service.
jenkins_plugin 'git' do
  version '2.2.1'
end

jenkins_plugin 'git-client' do
  version '1.9.1'
end

jenkins_plugin 'config-file-provider' do
  version '2.7.5'
  notifies :restart, 'service[jenkins]', :immediately
end
