# encoding: UTF-8
require 'rexml/document'
require 'set'

# module useful in chef recipes
module JenkinsUtils
  def git_class
    "@class = 'hudson.plugins.git.GitSCM'"
  end

  def git_plugin
    "@plugin = 'git@2.2.1'"
  end

  def jenkins_home(node)
    node['jenkins']['master']['home']
  end

  def job_exists?(node, job_name)
    ::File.exist?("#{jenkins_home(node)}/jobs/#{job_name}/config.xml")
  end

  def job_disabled?(node, job_name)
    job_doc(node, job_name).elements["/project/disabled[text() = 'true']"]
  end

  def job_changed?(node, cr)
    doc = job_doc(node, cr.name)
    if description(doc, cr.description) != cr.description\
      || keep_deps(doc, cr.keep_dependencies) != cr.keep_dependencies\
      || repo_txt(doc, cr.git_repo_url) != cr.git_repo_url\
      || branch_txt(doc, cr.git_branch) != cr.git_branch\
      || can_roam(doc, cr.can_roam) != cr.can_roam\
      || disabled(doc, cr.job_disabled) != cr.job_disabled\
      || block_downstream(doc, cr.block_downstream) != cr.block_downstream\
      || block_upstream(doc, cr.block_upstream) != cr.block_upstream\
      || concurrent_build(doc, cr.concurrent_build) != cr.concurrent_build\
      || commands(doc, cr.commands) != cr.commands\
      || managed_files(doc) != cr.managed_files\
      || rvm_env_txt(doc, cr.rvm_env) != cr.rvm_env
      return true
    end
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
    text_el(doc, init, '/project/description')
  end

  def keep_deps(doc, init)
    text_el(doc, init, '/project/keepDependencies')
  end

  def repo_txt(doc, init)
    urc = 'userRemoteConfigs/hudson.plugins.git.UserRemoteConfig/url'
    text_el(doc, init, "/project/scm[#{git_class} and #{git_plugin}]/#{urc}")
  end

  def branch_txt(doc, init)
    git_branch = 'branches/hudson.plugins.git.BranchSpec/name'
    branch_txt = init
    branch_el =
      doc.elements["/project/scm[#{git_class} and #{git_plugin}]/#{git_branch}"]
    branch_txt = branch_el.text[2..-1] unless branch_el.nil?
    branch_txt
  end

  def can_roam(doc, init)
    text_el(doc, init, '/project/canRoam')
  end

  def disabled(doc, init)
    text_el(doc, init, '/project/disabled')
  end

  def block_downstream(doc, init)
    text_el(doc, init, '/project/blockBuildWhenDownstreamBuilding')
  end

  def block_upstream(doc, init)
    text_el(doc, init, '/project/blockBuildWhenUpstreamBuilding')
  end

  def concurrent_build(doc, init)
    text_el(doc, init, '/project/concurrentBuild')
  end

  def commands(doc, init)
    command_lines(doc).nil? ? init : command_lines(doc)
  end

  def rvm_env_txt(doc, init)
    pre = '/project/buildWrappers/ruby-proxy-object/ruby-object'
    c1 = "@ruby-class = 'Jenkins::Plugin::Proxies::BuildWrapper'"
    p1 = "@pluginid = 'rvm'"
    c2 = "@ruby-class = 'RvmWrapper'"
    p2 = "@pluginid = 'rvm'"
    impl = "/impl[@pluginid = 'rvm' and @ruby-class = 'String'"
    rvm_env_txt = init
    rvm_env_el =
      doc.elements["#{pre}[#{c1} and #{p1}]/object[#{c2} and #{p2}]#{impl}]"]
    rvm_env_txt = rvm_env_el.text unless rvm_env_el.nil?
    rvm_env_txt
  end

  def command_lines(doc)
    @command_lines ||=
      begin
        cmd_el = doc.elements['/project/builders/hudson.tasks.Shell/command']
        command_txt = cmd_el.text
        command_lines = command_txt.split('\n')
        command_lines.reject! { |line| line.empty? || line.match(/^\s+$/) }
        command_lines.each { |line| line.strip! }
      end
  end

  def managed_files(doc)
    pre1 = '/project/buildWrappers'
    pre2 = '/org.jenkinsci.plugins.configfiles.buildwrapper'
    pre3 = '.ConfigFileBuildWrapper'
    plg = "@plugin = 'config-file-provider@2.7.4']/managedFiles"
    @managed_files ||= begin
                         mfs = []
                         mf_els = doc.elements["#{pre1}#{pre2}#{pre3}[#{plg}"]
                         mf_els.elements.each do |mf_el|
                           fileid_el = mf_el.elements['fileId']
                           target_location_el = mf_el.elements['targetLocation']
                           mfs << { file_id:  fileid_el.text,
                                    target_location: target_location_el.text }
                         end
                         mfs
                       end
  end

  def job_file(node, job_name)
    ::File.new("#{jenkins_home(node)}/jobs/#{job_name}/config.xml")
  end

  def job_doc(node, job_name)
    file = job_file(node, job_name)
    doc = REXML::Document.new file
    file.close
    doc
  end

  # various routines for dealing with the ConfigFileProvider plugin to Jenkins
  module ConfigFileProvider
    def jenkins_home(node)
      node['jenkins']['master']['home']
    end

    def remove_custom_file(node, id)
      script_path = "#{Chef::Config[:file_cache_path]}/removeCustomFile.groovy"
      template script_path do
        source 'removeCustomFile.groovy.erb'
        cookbook 'jenkins_utils'
        user node['jenkins']['master']['user']
        group node['jenkins']['master']['group']
        mode 00644
        variables(
          id: id
        )
      end

      remove_custom_file_script = ::File.new(script_path)
      jenkins_execute 'execute remove groovy script' do
        command remove_custom_file_script.read
      end
      remove_custom_file_script.close
    end

    def custom_file_exists?(node, id)
      cf = config_files(node)
      return true if !cf.nil? && cf.key?(id)
      false
    end

    def custom_file_changed?(node, id, name, comment, content)
      config_files(node)[id] == { id:  id, name: name,
                                  comment: comment, content: content }
    end

    def config_files(node)
      jenkins_pkg_str = 'org.jenkinsci.plugins.configfiles.custom.CustomConfig'
      ccf = "#{jenkins_home(node)}/custom-config-files.xml"
      @config_files ||=
        begin
          config_files = {}
          if ::File.exist?(ccf)
            file = ::File.new(ccf)
            doc = REXML::Document.new file
            file.close
            configs_el = doc.elements["/#{jenkins_pkg_str}Provider[@plugin = \
              'config-file-provider@2.7.4']/configs"]
            configs_el.elements.each do |entry|
              key = entry.elements['string'].text
              id = entry.elements["#{jenkins_pkg_str}/id"].text
              name = entry.elements["#{jenkins_pkg_str}/name"].text
              comment = entry.elements["#{jenkins_pkg_str}/comment"].text
              content = entry.elements["#{jenkins_pkg_str}/content"].text
              config_files[key] = { id: id, name: name, comment: comment,
                                    content: content }
            end
          end
        end
    end
  end
end
