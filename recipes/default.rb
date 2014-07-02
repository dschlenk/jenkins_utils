#
# Cookbook Name:: jenkins_utils
# Recipe:: default
#
# This recipe sets up a Jenkins CI master server and installs the plugins
# and packages required to use the LWRPs in this cookbook.
#
# Author:: David Schlenk <david.schlenk@spanlink.com>
# Copyright (C) 2014 Spanlink Communications
#
# Apache 2.0
#

include_recipe 'jenkins_utils::master'
include_recipe 'jenkins_utils::deps'
