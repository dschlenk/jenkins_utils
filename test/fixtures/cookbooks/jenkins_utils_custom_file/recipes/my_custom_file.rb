include_recipe 'jenkins_utils::default'

jenkins_utils_custom_file 'my-custom-file-name' do
  id 'my-custom-file-id'
  comment 'my-custom-file-comment'
  content 'my-custom-file-content'
end
