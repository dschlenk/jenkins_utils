# encoding: UTF-8

# Resource for creating a Jenkins job that tests chef cookbooks.
# Assumptions:
# * Using git for version control
# * Using rake to define test tasks
actions :create, :create_if_missing, :disable, :delete, :enable
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :description, kind_of: String, default: nil
attribute :keep_dependencies, kind_of: [TrueClass, FalseClass], default: false
attribute :git_repo_url, kind_of: String, required: true
attribute :git_branch, kind_of: String, default: 'master'
attribute :can_roam, kind_of: [TrueClass, FalseClass], default: true
attribute :job_disabled, kind_of: [TrueClass, FalseClass], default: false
attribute :block_downstream, kind_of: [TrueClass, FalseClass], default: false
attribute :block_upstream, kind_of: [TrueClass, FalseClass], default: false
attribute :concurrent_build, kind_of: [TrueClass, FalseClass], default: false
attribute :commands, kind_of: Array, default: ['bundle install --deployment',
                                               'bundle exec rake']
# Array of hashes containing keys 'file_id', 'target_location'
attribute :managed_files, kind_of: Array, default: []
attribute :rvm_env, kind_of: String, default: '1.9.3'

attr_accessor :exists, :disabled, :changed
