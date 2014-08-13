# encoding: UTF-8
require 'spec_helper'

describe 'jenkins_utils::default' do
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set[:runit][:sv_bin] = '/usr/bin/sv'
    end.converge(described_recipe)
  end

  it 'includes master recipe' do
    expect(chef_run).to include_recipe('jenkins_utils::master')
  end

  it 'includes deps recipe' do
    expect(chef_run).to include_recipe('jenkins_utils::deps')
  end
end
