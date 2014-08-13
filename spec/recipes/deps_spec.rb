# encoding: UTF-8
require 'spec_helper'

describe 'jenkins_utils::deps' do
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set[:runit][:sv_bin] = '/usr/bin/sv'
      node.set[:rvm][:install_pkgs] = %w{git}
    end.converge(described_recipe)
  end

  it 'includes default git recipe' do
    expect(chef_run).to include_recipe('git::default')
  end

  it 'includes user rvm recipe' do
    expect(chef_run).to include_recipe('rvm::user')
  end

  it 'installs jenkins plugin scm-api' do
    expect(chef_run).to install_jenkins_plugin('scm-api')
  end

  it 'installs jenkins plugin token-macro' do
    expect(chef_run).to install_jenkins_plugin('token-macro')
  end

  it 'installs jenkins plugin ant' do
    expect(chef_run).to install_jenkins_plugin('ant')
  end

  it 'installs jenkins plugin javadoc' do
    expect(chef_run).to install_jenkins_plugin('javadoc')
  end

  it 'installs jenkins plugin maven-plugin' do
    expect(chef_run).to install_jenkins_plugin('maven-plugin')
  end

  it 'installs jenkins plugin analysis-core' do
    expect(chef_run).to install_jenkins_plugin('analysis-core')
  end

  it 'installs jenkins plugin violations' do
    expect(chef_run).to install_jenkins_plugin('violations')
  end

  it 'installs jenkins plugin dashboard-view' do
    expect(chef_run).to install_jenkins_plugin('dashboard-view')
  end

  it 'installs jenkins plugin warnings' do
    expect(chef_run).to install_jenkins_plugin('warnings')
  end

  it 'installs jenkins plugin ruby-runtime' do
    expect(chef_run).to install_jenkins_plugin('ruby-runtime')
  end

  it 'installs jenkins plugin rvm' do
    expect(chef_run).to install_jenkins_plugin('rvm')
  end

  it 'installs jenkins plugin git' do
    expect(chef_run).to install_jenkins_plugin('git')
  end

  it 'installs jenkins plugin git-client' do
    expect(chef_run).to install_jenkins_plugin('git-client')
  end

  it 'installs jenkins plugin config-file-provider' do
    expect(chef_run).to install_jenkins_plugin('config-file-provider')
  end

end
