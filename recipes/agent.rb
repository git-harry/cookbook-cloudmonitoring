include_recipe 'cloud_monitoring::repo'

platform_options = node['cloud_monitoring']['platform']

databag_dir = node["cloud_monitoring"]["credentials"]["databag_name"]
databag_filename = node["cloud_monitoring"]["credentials"]["databag_item"]
begin
  values = Chef::EncryptedDataBagItem.load(databag_dir, databag_filename)
rescue Exception => e
  Chef::Log.warn 'Failed to load rackspace cloud data bag: ' + e.to_s
  values = {}
end

token = values['token'] || node['cloud_monitoring']['agent_token']['token']

package "rackspace-monitoring-agent" do
  if node['cloud_monitoring']['agent']['version'] == 'latest'
    action :upgrade
  else
    version node['cloud_monitoring']['agent']['version']
    action :install
  end

  notifies :restart, "service[#{platform_options['service']}]"
end

template "/etc/rackspace-monitoring-agent.cfg" do
  source "rackspace-monitoring-agent.erb"
  owner "root"
  group "root"
  mode 0600
  variables(
    :monitoring_id => node['cloud_monitoring']['agent']['id'],
    :monitoring_token => token
  )
end

service platform_options['service'] do
  # TODO: RHEL, CentOS, ... support
  supports value_for_platform(
    "ubuntu" => { "default" => [:start, :stop, :restart, :status] },
    "default" => { "default" => [:start, :stop] }
  )

  case node['platform']
  when "ubuntu"
    if node['platform_version'].to_f >= 9.10
      provider Chef::Provider::Service::Upstart
    end
  end

  action [:enable, :start]
  subscribes :restart, 'template[/etc/rackspace-monitoring-agent.cfg]', :delayed
end
