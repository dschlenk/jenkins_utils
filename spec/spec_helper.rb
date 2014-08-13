# encoding: UTF-8
require 'rspec/expectations'
require 'chefspec'
require 'chefspec/berkshelf'

Dir['libraries/*.rb'].each { |f| require File.expand_path(f) }
