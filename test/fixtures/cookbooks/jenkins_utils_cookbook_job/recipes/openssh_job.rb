# encoding: UTF-8
include_recipe 'jenkins_utils::default'

jenkins_utils_custom_file 'my-custom-file-name' do
  id 'my-custom-file-id'
  comment 'my-custom-file-comment'
  content 'my-custom-file-content'
end

jenkins_utils_cookbook_job 'chef-openssh' do
  description 'Job to test the Chef cookbook that installs the openssh package.'
  git_repo_url 'https://github.com/opscode-cookbooks/openssh.git'
  git_branch 'master'
  commands ['bundle exec rspec', 'bundle exec foodcritic .',
            'bundle exec rubocop', 'bundle exec kitchen test']
  managed_files [{ 'file_id' => 'my-custom-file-id' },
                 { 'target_location' => 'custom-file' }]
  rvm_env '1.9.3'
end
