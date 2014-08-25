# encoding: UTF-8
include_recipe 'jenkins_utils::default'

jenkins_utils_custom_file 'my-custom-file-name' do
  comment 'my-custom-file-comment'
  content ['my-custom-file-content']
end

jenkins_utils_cookbook_job 'chef-openssh' do
  description 'Job to test the Chef cookbook that installs the openssh package.'
  git_repo_url 'https://github.com/opscode-cookbooks/openssh.git'
  git_branch 'master'
  auth_token 'magic'
  build_timers ['H * * * * ', 'H H * * *']
  scm_poll_timers ['H H * * * ', 'H * * * *']
  ignore_post_commit_hooks true
  commands ['bundle exec rspec', 'bundle exec foodcritic .',
            'bundle exec rubocop', 'bundle exec kitchen test']
  managed_files [{ 'file_name' => 'my-custom-file-name',
                   'target_location' => 'custom-file' }]
  rvm_env '1.9.3'
end
