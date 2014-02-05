# Cookbook Name:: redmine
# Recipe:: source
#
# Copyright 2012, Juanje Ojeda <juanje.ojeda@gmail.com>
# Copyright 2013, Roberto Majadas <roberto.majadas@openshine.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

rbenv_ruby "2.0.0-p353"

rbenv_global "2.0.0-p353"

rbenv_gem "bundler" do
  rbenv_version   "2.0.0-p353"
  action          :install
end

# Some handy vars
environment = node['redmine']['env']
adapter = node["redmine"]["databases"][environment]["adapter"]

#Setup system package manager
include_recipe "apt"

#Install redmine required dependencies
node['redmine']['packages']['apache'].each do |pkg|
  package pkg
end
node['redmine']['packages']['scm'].each do |pkg|
  package pkg
end

if node['redmine']['install_rmagick']
  node['redmine']['packages']['rmagick'].each do |pkg|
    package pkg
  end
end

#Setup database
package 'libmysqlclient-dev'
case adapter
when "mysql"
  include_recipe "mysql::client"
  include_recipe "mysql::ruby"
when "postgresql"
  include_recipe "postgresql::server"
  include_recipe "database::postgresql"
end

#Setup Apache
include_recipe "apache2"
apache_site "000-default" do
  enable false
  notifies :restart, "service[apache2]"
end

web_app "redmine" do
  docroot        ::File.join(node['redmine']['path'], 'public')
  template       "redmine.conf.erb"
  server_name    "redmine.#{node['domain']}"
  server_aliases [ "redmine", node['hostname'] ]
  rails_env      environment
end

# deploy the Redmine app
include_recipe "git"
deploy_revision node['redmine']['deploy_to'] do
  repo     node['redmine']['repo']
  revision node['redmine']['revision']
  user     node['apache']['user']
  group    node['apache']['group']
  environment "RAILS_ENV" => environment

  before_migrate do
    %w{config log system pids}.each do |dir|
      directory "#{node['redmine']['deploy_to']}/shared/#{dir}" do
        owner node['apache']['user']
        group node['apache']['group']
        mode '0755'
        recursive true
      end
    end

    template "#{node['redmine']['deploy_to']}/shared/config/database.yml" do
      source "database.yml.erb"
      owner node['apache']['user']
      group node['apache']['group']
      mode "644"
      variables(
        :db   => node['redmine']['databases'][environment],
        :rails_env => environment
      )
    end

    execute "bundle install --without development test postgresql sqlite" do
      cwd release_path
    end

    execute 'bundle exec rake generate_secret_token' do
      cwd release_path
      not_if { ::File.exists?("#{release_path}/config/initializers/secret_token.rb") }
    end

  end

  migrate false
  #migration_command 'rake db:migrate'

  create_dirs_before_symlink %w{tmp public config tmp/pdf public/plugin_assets}

  before_restart do
    link node['redmine']['path'] do
      to release_path
    end
  end

  action :deploy
  notifies :restart, "service[apache2]"
end
