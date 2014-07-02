source 'https://rubygems.org'

group :lint do
  gem 'foodcritic', '~> 3.0'
  gem 'rubocop', '~> 0.18'
  gem 'rainbow', '< 2.0'
  gem 'rake'
end

group :unit do
  gem 'berkshelf', '~> 3.0'
  gem 'chefspec', '~> 3.2'
end

group :kitchen_common do
  gem 'test-kitchen', '~> 1.2'
end

group :kitchen_vagrant do
  gem 'kitchen-vagrant', '~> 0.11'
end

group :kitchen_cloud do
  gem 'kitchen-digitalocean'
  gem 'kitchen-ec2'
  gem 'kitchen-openstack', :git => 'git://github.com/dschlenk/kitchen-openstack', :branch => 'hostname_limit'
  gem 'kitchen-rackspace'
end
