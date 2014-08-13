# encoding: UTF-8
actions :create, :create_if_missing, :delete
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :id, kind_of: String, required: true
attribute :comment, kind_of: String
attribute :content, kind_of: String

attr_accessor :exists, :changed
