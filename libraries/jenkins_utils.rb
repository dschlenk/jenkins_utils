require 'rexml/document'
require 'set'

module JenkinsUtils
  def job_exists?(node, job_name)
    ::File.exists?("#{node['jenkins']['master']['home']}/jobs/#{job_name}/config.xml")
  end
  
  def job_disabled?(node, job_name)
    job_doc(node, job_name).elements["/project/disabled[text() = 'true']"]
  end

  def job_changed?(node, current_resource)
    doc = job_doc(node, current_resource.name)

    return true if description(doc, current_resource.description) != current_resource.description
    return true if keep_deps(doc, current_resource.keep_dependencies) != current_resource.keep_dependencies
    return true if repo_txt(doc, current_resource.git_repo_url) != current_resource.git_repo_url
    return true if branch_txt(doc, current_resource.git_branch) != current_resource.git_branch
    return true if can_roam(doc, current_resource.can_roam) != current_resource.can_roam
    return true if disabled(doc, current_resource.job_disabled) != current_resource.job_disabled
    return true if block_downstream(doc, current_resource.block_downstream) != current_resource.block_downstream
    return true if block_upstream(doc, current_resource.block_upstream) != current_resource.block_upstream
    return true if concurrent_build(doc, current_resource.concurrent_build) != current_resource.concurrent_build
    return true if commands(doc, current_resource.commands) != current_resource.commands
    return true if managed_files(doc) != current_resource.managed_files
    return true if rvm_env_txt(doc, current_resource.rvm_env) != current_resource.rvm_env

    false
  end

  
  private

  def text_el(doc, init, xpath)
    text = init
    target_el = doc.elements[xpath]
    text = target_el.text unless target_el.nil?
    text
  end

  def description(doc, init)
    text_el(doc, init, "/project/description")
  end

  def keep_deps(doc, init)
    text_el(doc, init, "/project/keepDependencies")
  end
  
  def repo_txt(doc, init)
    text_el(doc, init, "/project/scm[@class = 'hudson.plugins.git.GitSCM' and @plugin = 'git@2.2.1']/userRemoteConfigs/hudson.plugins.git.UserRemoteConfig/url")
  end

  def branch_txt(doc, init)
    branch_txt = init
    branch_el = doc.elements["/project/scm[@class = 'hudson.plugins.git.GitSCM' and @plugin = 'git@2.2.1']/branches/hudson.plugins.git.BranchSpec/name"]
    branch_txt = branch_el.text[2..-1] unless branch_el.nil?
    branch_txt
  end

  def can_roam(doc, init)
    text_el(doc, init, "/project/canRoam")
  end

  def disabled(doc, init)
    text_el(doc, init, "/project/disabled")
  end

  def block_downstream(doc, init)
    text_el(doc, init, "/project/blockBuildWhenDownstreamBuilding")
  end

  def block_upstream(doc, init)
    text_el(doc, init, "/project/blockBuildWhenUpstreamBuilding")
  end

  def concurrent_build(doc, init)
    text_el(doc, init, "/project/concurrentBuild")
  end

  def commands(doc, init)
    command_lines(doc).nil? ? init : command_lines(doc)
  end

  def rvm_env_txt(doc, init)
    rvm_env_txt = init
    rvm_env_el = doc.elements["/project/buildWrappers/ruby-proxy-object/ruby-object[@ruby-class = 'Jenkins::Plugin::Proxies::BuildWrapper' and @pluginid = 'rvm']/object[@ruby-class = 'RvmWrapper' and @pluginid = 'rvm']/impl[@pluginid = 'rvm' and @ruby-class = 'String']"]
    rvm_env_txt = rvm_env_el.text unless rvm_env_el.nil?
    rvm_env_txt
  end

  def command_lines(doc)
    @command_lines ||= begin
                         command_el = doc.elements["/project/builders/hudson.tasks.Shell/command"]
                         command_txt = command_el.text
                         command_lines = command_txt.split("\n")
                         command_lines.reject!{ |line| line.empty?|| line.match(/^\s+$/) }
                         command_lines.each {|line| line.strip!}
                       end
  end
  

  def managed_files(doc)
    @managed_files ||= begin
                         mfs = []
                         mf_els = doc.elements["/project/buildWrappers/org.jenkinsci.plugins.configfiles.buildwrapper.ConfigFileBuildWrapper[@plugin = 'config-file-provider@2.7.4']/managedFiles"]
                         mf_els.elements.each do |mf_el|
                           fileid_el = mf_el.elements["fileId"]
                           target_location_el = mf_el.elements["targetLocation"]
                           mfs << { 'file_id' => fileid_el.text, 'target_location' => target_location_el.text }
                         end
                         managed_files = mfs
                       end
  end

  def job_file(node, job_name)
    ::File.new("#{node['jenkins']['master']['home']}/jobs/#{job_name}/config.xml")
  end

  def job_doc(node, job_name)
    file = job_file(node, job_name)
    doc = REXML::Document.new file
    file.close
    doc
  end

  module ConfigFileProvider 

    def remove_custom_file(node, id)
      script_path = "#{Chef::Config[:file_cache_path]}/removeCustomFile.groovy"
      template script_path do
        source "removeCustomFile.groovy.erb"
        cookbook 'jenkins_utils'
        user node['jenkins']['master']['user']
        group node['jenkins']['master']['group']
        mode 00644
        variables({
          :id => id
        })
      end
        
      remove_custom_file_script = ::File.new(script_path)
      jenkins_execute "execute remove groovy script" do
        command remove_custom_file_script.read
      end
      remove_custom_file_script.close
    end

    def custom_file_exists?(node, id)
      cf = config_files(node)
      if(!cf == nil)
        if(cf.has_key? id)
          return true
        end
      end
      false
    end

    def custom_file_changed?(node, id, name, comment, content)
      config_files(node)[id] == {'id' => id, 'name' => name, 'comment' => comment, 'content' => content}
    end

    def config_files(node)
      @config_files ||= begin
                          config_files = {}
                          if ::File.exists?("#{node['jenkins']['master']['home']}/custom-config-files.xml")
                            file = ::File.new("#{node['jenkins']['master']['home']}/custom-config-files.xml")
                            doc = REXML::Document.new file
                            file.close
                            configs_el = doc.elements["/org.jenkinsci.plugins.configfiles.custom.CustomConfigProvider[@plugin = 'config-file-provider@2.7.4']/configs"]
                            configs_el.elements.each do |entry| 
                              key = entry.elements["string"].text
                              id = entry.elements["org.jenkinsci.plugins.configfiles.custom.CustomConfig/id"].text
                              name = entry.elements["org.jenkinsci.plugins.configfiles.custom.CustomConfig/name"].text
                              comment = entry.elements["org.jenkinsci.plugins.configfiles.custom.CustomConfig/comment"].text
                              content = entry.elements["org.jenkinsci.plugins.configfiles.custom.CustomConfig/content"].text
                              config_files[key] = {'id' => id, 'name' => name, 'comment' => comment, 'content' => content}
                            end
                          end
                        end
    end
  end
end
