# encoding: UTF-8
#
# Cookbook Name:: jenkins_utils
# Recipe:: master
#
# This recipe sets up a Jenkins CI master server. This recipe in conjunction
# with the deps recipe enables the use the LWRPs in this cookbook.
#
# Most users will likely want to write their own version of this recipe and
# only include the deps recipe from this cookbook in their run list.
# Additionally, slave nodes could be added to the cluster - they will
# also need the deps recipe in their run list.
#
# Author:: David Schlenk <david.schlenk@spanlink.com>
# Copyright (C) 2014 Spanlink Communications
#
# Apache 2.0
#
node.set['jenkins']['master']['install_method'] = 'war'
#node.set['jenkins']['master']['version'] = '1.555'
node.set['jenkins']['executor']['timeout'] = 300

mirror = node['jenkins']['master']['mirror']
version = node['jenkins']['master']['version']

Chef::Log.info("Jenkins Version: #{version}")

node.set['jenkins']['master']['source'] = "#{mirror}/war/#{version}/jenkins.war"

# Dependency recipes
include_recipe 'java::default'
include_recipe 'jenkins::master'
