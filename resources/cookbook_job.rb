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
# when present, enables remote build triggering using URL
# /job/NAME/build?token=AUTH_TOKEN
attribute :auth_token, kind_of: String
# Array of strings that follow the Jenkins cron-based format:
# http://stackoverflow.com/questions/12472645/how-to-schedule-jobs-in-jenkins
# Performs builds accordingly.
attribute :build_timers, kind_of: Array
# Array of strings like above. Will check for changes in SCM on this schedule
# and build when changes detected.
attribute :scm_poll_timers, kind_of: Array
# only relevant if above exists
attribute :ignore_post_commit_hooks, kind_of: [TrueClass, FalseClass],
                                     default: false
attribute :concurrent_build, kind_of: [TrueClass, FalseClass], default: false
attribute :commands, kind_of: Array, default: ['bundle install --deployment',
                                               'bundle exec rake']
# Array of hashes containing keys 'file_id', 'target_location'
# and optionally 'variable'
attribute :managed_files, kind_of: Array, default: []
attribute :rvm_env, kind_of: String, default: '1.9.3'

attr_accessor :exists, :disabled, :changed
