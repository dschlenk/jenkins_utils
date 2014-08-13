# encoding: UTF-8
require 'spec_helper'

describe 'jenkins_utils::master' do
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set[:runit][:sv_bin] = '/usr/bin/sv'
    end.converge(described_recipe)
  end

  it 'includes default java recipe' do
    expect(chef_run).to include_recipe('java::default')
  end

  it 'includes master jenkins recipe' do
    expect(chef_run).to include_recipe('jenkins::master')
  end
end
