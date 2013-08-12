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
default['cloud_monitoring']['rackspace_monitoring_version'] = '0.2.18'
default['cloud_monitoring']['checks'] = {}
default['cloud_monitoring']['alarms'] = {}
default['cloud_monitoring']['rackspace_username'] = 'your_rackspace_username'
default['cloud_monitoring']['rackspace_api_key'] = 'your_rackspace_api_key'
default['cloud_monitoring']['rackspace_auth_url'] = 'https://auth.api.rackspacecloud.com/v1.0'
default['cloud_monitoring']['abort_on_failure'] = true

default['cloud_monitoring']['guess_resource'] = true

default['cloud_monitoring']['entity']['id'] = nil
#Do not change the default label value for a Rackspace Public Cloud Server
default['cloud_monitoring']['entity']['label'] = node['hostname']
#If left as nil it will be set to include the server's IPv4 and IPv6 addresses
#This should be nil for a Rackspace Public Cloud Server, the entity recipe will
#update it with the correct value
default['cloud_monitoring']['entity']['ip_addresses'] = nil

default['cloud_monitoring']['agent']['id'] = node['fqdn'] + '-' + node['ipaddress']
default['cloud_monitoring']['agent']['channel'] = nil
default['cloud_monitoring']['agent']['version'] = 'latest'
default['cloud_monitoring']['agent_token']['id'] = nil
default['cloud_monitoring']['agent_token']['token'] = nil
default['cloud_monitoring']['agent_token']['label'] = node['fqdn']
default['cloud_monitoring']['monitoring_endpoints'] = [] # This should be a list of strings like 'x.x.x.x:port'

default['cloud_monitoring']['plugin_path'] = '/usr/lib/rackspace-monitoring-agent/plugins'
# This looks a little weird but is intentional so that this cookbook and its
# plugins directory always gets included in the list of plugins and won't get overwriten by
# a role or node attribute.
default['cloud_monitoring']['plugins']['cloud_monitoring'] = 'plugins'

default['cloud_monitoring']['credentials']['databag_name'] = 'rackspace'
default['cloud_monitoring']['credentials']['databag_item'] = 'cloud'

if platform_family?('debian')
  if platform?('ubuntu')
    repo_uri = "http://stable.packages.cloudmonitoring.rackspace.com/ubuntu-#{node['platform_version']}-#{node['kernel']['machine']}"
  else
    repo_uri = "http://stable.packages.cloudmonitoring.rackspace.com/debian-#{node['lsb']['codename']}-#{node['kernel']['machine']}"
  end
  default['cloud_monitoring']['platform'] = {
    'gems_require_packages' => ['libxslt-dev', 'libxml2-dev', 'build-essential'],
    'monitoring_gem' => 'rackspace-monitoring',
    'ruby_dev_package' => 'ruby-dev',
    'repo_uri' => repo_uri,
    'repo_key' => "https://monitoring.api.rackspacecloud.com/pki/agent/linux.asc",
    'service' => 'rackspace-monitoring-agent'
  }
elsif platform_family?('rhel')
  releaseVersion = node['platform_version'].split('.').first
  if (node['platform'] == 'centos') && (releaseVersion == '5')
    repo_key = 'https://monitoring.api.rackspacecloud.com/pki/agent/centos-5.asc'
  elsif (node['platform'] == 'redhat') && (releaseVersion == '5')
    repo_key = 'https://monitoring.api.rackspacecloud.com/pki/agent/redhat-5.asc'
  else
    repo_key = 'https://monitoring.api.rackspacecloud.com/pki/agent/linux.asc'
  end
  default['cloud_monitoring']['platform'] = {
    'gems_require_packages' => ['libxslt-devel', 'libxml2-devel', 'make', 'gcc'],
    'monitoring_gem' => 'rackspace-monitoring',
    'ruby_dev_package' => 'ruby-devel',
    'repo_uri' => "http://stable.packages.cloudmonitoring.rackspace.com/#{node['platform']}-#{releaseVersion}-#{node['kernel']['machine']}",
    'repo_key' => repo_key,
    'service' => 'rackspace-monitoring-agent'
  }
else
  Chef::Application.fatal("The platform family #{node['platform_family']} is not supported.", 1)
end
