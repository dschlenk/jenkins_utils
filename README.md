jenkins_utils
==================

Resources / providers for managing Jenkins CI jobs with Chef. 

Leveraging this cookbook and the official [Jenkins cookbook](https://github.com/opscode-cookbooks/jenkins) 
you can easily add jobs to test your Chef cookbooks to a Jenkins CI server. 

Usage
-----

You'll need a Jenkins CI server managed by Chef. This cookbook's `default` recipe will take care of this for you, or (more likely) you can write your own master and slave recipes and add the `deps` recipe from this cookbook to those systems. You can then use the LWRPs listed below to aid in the management of your Jenkins CI jobs. 

LWRPs
-----

### jenkins_utils_custom_file

Use this resource to make custom config files available to jobs in Jenkins. Uses the `config-file-provider` Jenkins plugin. At this time all files use the custom (plain text) type but adding additional LWRPs for the other file types supported by this plugin would be trivial. This resource is especially useful for overriding test kitchen configurations (using a `.kitchen.local.yml` file).   Example usage: 

```
jenkins_utils_custom_file ".kitchen.local.yml-openstack" do
  id '.kitchen.local.yml-openstack'
  comment 'Change test kitchen driver to openstack'
  content <<-EOH.gsub(/^ {4}/, '')
    ---
    driver:
      name: openstack
  EOH
end
```

### jenkins_utils_cookbook_job

Use this resource to add jobs that test cookbooks. Example: 

```
jenkins_utils_cookbook_job "sudo" do
  description 'Job to test the Chef cookbook that installs the openssh package.'
  git_repo_url 'https://github.com/opscode-cookbooks/openssh.git'
  git_branch 'master'
  commands ['bundle exec rspec', 'bundle exec foodcritic .', 'bundle exec rubocop', 'bundle exec kitchen test']
  managed_files [{'file_id' => '.kitchen.local.yml-openstack'}, {'target_location' => '.kitchen.local.yml'}]
  rvm_env '1.9.3'
end
```

This will add a job that tests the official openssh cookbook. Note that it includes a managed_files attribute that references the ID of the custom file we added in the previous resource!
