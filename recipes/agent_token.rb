include_recipe 'cloud_monitoring::default'

label = node['cloud_monitoring']['agent_token']['label']

databag_dir = node["cloud_monitoring"]["credentials"]["databag_name"]
databag_filename = node["cloud_monitoring"]["credentials"]["databag_item"]
begin
  values = Chef::EncryptedDataBagItem.load(databag_dir, databag_filename)
rescue Exception => e
  Chef::Log.warn 'Failed to load rackspace cloud data bag: ' + e.to_s
  values = {}
end

if not values['agent_token']
  username = values['username'] ||
    node['cloud_monitoring']['rackspace_username']
  api_key = values['apikey'] || node['cloud_monitoring']['rackspace_api_key']

  create_token = cloud_monitoring_agent_token label do
    rackspace_username  username
    rackspace_api_key  api_key
    rackspace_auth_url node['cloud_monitoring']['rackspace_auth_url']
    action :nothing
  end

  create_token.run_action(:create)
end
