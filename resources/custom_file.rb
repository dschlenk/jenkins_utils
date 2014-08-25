# encoding: UTF-8
actions :create, :create_if_missing, :delete
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :comment, kind_of: String
# Array of strings (lines of content)
attribute :content, kind_of: Array

attr_accessor :exists, :changed
