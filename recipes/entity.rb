include_recipe 'cloud_monitoring::default'

label = node['cloud_monitoring']['entity']['label']

databag_dir = node["cloud_monitoring"]["credentials"]["databag_name"]
databag_filename = node["cloud_monitoring"]["credentials"]["databag_item"]
begin
  values = Chef::EncryptedDataBagItem.load(databag_dir, databag_filename)
rescue Exception => e
  Chef::Log.warn 'Failed to load rackspace cloud data bag: ' + e.to_s
  values = {}
end

username = values['username'] || node['cloud_monitoring']['rackspace_username']
api_key = values['apikey'] || node['cloud_monitoring']['rackspace_api_key']

ipaddrs = node['cloud_monitoring']['entity']['ip_addresses']
if node.attribute?('rackspace')
  #this should be a Rackspace public cloud server
  ipaddrs = nil
elsif node['cloud_monitoring']['entity']['ip_addresses'].nil?
  ipaddrs = { 'ipv4' => node['ipaddress'], 'ipv6' => node['ip6address'] }
end

create_entity = cloud_monitoring_entity label do
  ip_addresses ipaddrs
  agent_id node['cloud_monitoring']['agent']['id']
  rackspace_username username
  rackspace_api_key api_key
  rackspace_auth_url node['cloud_monitoring']['rackspace_auth_url']
  action :nothing
end

create_entity.run_action(:create)
