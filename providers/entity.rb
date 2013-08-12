include Rackspace::CloudMonitoring

require 'ipaddr'

action :create do
  # normalize the ip's
  if new_resource.ip_addresses then
    new_resource.ip_addresses.each_value { |v| IPAddr.new(v) }
  end
  entity = cm.entities.new(
    :label => new_resource.label,
    :ip_addresses => new_resource.ip_addresses,
    :metadata => new_resource.metadata,
    :agent_id => new_resource.agent_id
  )
  if @current_resource.nil? then
    Chef::Log.info("Creating #{new_resource}")
    entity.save
    new_resource.updated_by_last_action(true)
    if not entity.id
      clear
      entity = get_entity_by_label_and_ip(new_resource.label, node['ipaddress'])
    end
    node.set['cloud_monitoring']['entity']['id'] = entity.id
    #If a Rackspace Public Cloud Server the IP addresses entity attribute
    #is immutable so we can only update the node with its current value
    node.set['cloud_monitoring']['entity']['ip_addresses'] = entity.ip_addresses
    clear
  else
    # Compare attributes
    if !entity.compare? @current_resource then
      # It's different
      Chef::Log.info("Updating #{new_resource}")
      entity.id = @current_resource.id
      entity.save
      new_resource.updated_by_last_action(true)
      clear
    else
      Chef::Log.debug("#{new_resource} matches, skipping")
      new_resource.updated_by_last_action(false)
    end
  end
end

action :delete do
  if !@current_resource.nil? then
    @current_resource.destroy
    new_resource.updated_by_last_action(true)
    clear
    node.set['cloud_monitoring']['entity']['id'] = nil
  else
    new_resource.updated_by_last_action(false)
  end
end


def load_current_resource
  @current_resource = get_entity_by_id node['cloud_monitoring']['entity']['id']
  if @current_resource == nil && node['cloud_monitoring']['guess_resource'] == true
    @current_resource = get_entity_by_label_and_ip(new_resource.label, node['ipaddress'])
    node.set['cloud_monitoring']['entity']['id'] = @current_resource.identity unless @current_resource.nil?
  end
end
