# encoding: UTF-8
include JenkinsUtils::ConfigFileProvider

def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists && !@current_resource.changed
    Chef::Log.info "#{ @new_resource } exists and not changed - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_custom_file
      new_resource.updated_by_last_action(true)
    end
  end
end

action :create_if_missing do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_custom_file
      new_resource.updated_by_last_action(true)
    end
  end
end

action :delete do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } exists - deleting."
    converge_by("Delete #{ @new_resource }") do
      delete_custom_file
      new_resource.updated_by_last_action(true)
    end
  else
    Chef::Log.info "#{ @new_resource } doesn't exist - nothing to do."
  end
end

def load_current_resource
  @current_resource =
    Chef::Resource::JenkinsUtilsCustomFile.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.id(@new_resource.id)
  @current_resource.comment(@new_resource.comment)
  @current_resource.content(@new_resource.content)

  return unless custom_file_exists?(node, @current_resource.id)
  @current_resource.exists = true
  @current_resource.changed = true if custom_file_changed?(
    node, @current_resource.id, @current_resource.name,
    @current_resource.comment, @current_resource.content)
end

private

def create_custom_file
  script_path = "#{Chef::Config[:file_cache_path]}/updateCustomFile.groovy"
  update_custom_file_script = write_script(new_resource.id, new_resource.name,
                                           new_resource.comment,
                                           new_resource.content,
                                           script_path)
  jenkins_script 'execute create/update groovy script' do
    command update_custom_file_script.read
  end
  update_custom_file_script.close
end

def write_script(id, name, comment, content, script_path)
  template script_path do
    source 'updateCustomFile.groovy.erb'
    cookbook 'jenkins_utils'
    owner node['jenkins']['master']['user']
    group node['jenkins']['master']['group']
    mode '00644'
    variables(id: id, name: name, comment: comment, content: content)
    action :nothing
  end.run_action(:create)
  ::File.new(script_path)
end

def delete_custom_file
  remove_custom_file(node, new_resource.id)
end
