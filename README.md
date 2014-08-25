jenkins_utils
==================

Resources / providers for managing Jenkins CI jobs with Chef. 

Leveraging this cookbook and the official [Jenkins cookbook](https://github.com/opscode-cookbooks/jenkins) 
you can easily add jobs to test your Chef cookbooks to a Jenkins CI server. 

Requirements
------------

* Chef 11+
* Ruby 1.9.3+

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
  content ['---', 'driver:', '  name: openstack']
end
```

Specify content as an array of strings representing the lines in the file. 

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

This will add a job that tests the official openssh cookbook. Note that it includes a managed_files attribute that references the ID of the custom file we added in the previous resource. See source and test fixtures for other options available including various build pipeline options, scheduling options and setting an auth token for ad-hoc/script triggered builds. 

Development
-----------

Pretty standard workflow: 

* Fork
* Write tests
* Make changes that implement tests
* `bundle install`
* `bundle exec rake`
* Submit a pull request

Authors
-------
* David Schlenk david.schlenk@spanlink.com

Roughly inspired/based on [Zachary Stevens'](mailto:zts@cryptocracy.com) [Cooking With Jenkins](https://github.com/zts/cooking-with-jenkins) cookbook. 

License
-------

```
Copyright 2014 Spanlink Communications, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
