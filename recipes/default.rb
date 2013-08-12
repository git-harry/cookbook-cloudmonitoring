#
# Cookbook Name:: cloud_monitoring
# Recipe:: default
#
# Copyright 2012, Rackspace
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

if platform_family?('debian')
  apt = execute "apt-get update" do
    action :nothing
  end

  timestamp_file = '/var/lib/apt/periodic/update-success-stamp'
  if !File.exists?(timestamp_file)
    apt.run_action(:run)
  elsif File.mtime(timestamp_file) < Time.now - 86400
    apt.run_action(:run)
  end
end

platform_options = node['cloud_monitoring']['platform']

platform_options['gems_require_packages'].each do |pkg|
  package(pkg).run_action(:install)
end

begin
  # chef_gem doesn't exist prior to 0.10.9
  chef_gem platform_options['monitoring_gem'] do
    version node['cloud_monitoring']['rackspace_monitoring_version']
    action :install
  end
rescue NameError => e
  Chef::Log.warn(
    "chef_gem resource doesn't exist, falling back to system ruby install")

  package(platform_options['ruby_dev_package']).run_action(:install)
  r = gem_package platform_options['monitoring_gem'] do
    version node['cloud_monitoring']['rackspace_monitoring_version']
    action :nothing
  end

  r.run_action(:install)

  require 'rubygems'
  Gem.clear_paths
end

require 'rackspace-monitoring'
