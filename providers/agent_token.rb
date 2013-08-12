include Rackspace::CloudMonitoring

action :create do
  agent_token = cm.agent_tokens.new(:label => new_resource.label)
  if @current_resource.nil? then
    Chef::Log.info("Creating #{new_resource}")
    agent_token.save
    new_resource.updated_by_last_action(true)
    if not agent_token.id
      clear_tokens
      agent_token = get_token_by_label agent_token.label
    end
    node.set['cloud_monitoring']['agent_token']['id'] = agent_token.id
    node.set['cloud_monitoring']['agent_token']['token'] = agent_token.token
    clear_tokens
  else
    Chef::Log.debug("#{new_resource} exists, skipping create")
    new_resource.updated_by_last_action(false)
  end
end


action :delete do
  if !@current_resource.nil? then
    Chef::Log.info("Deleting #{new_resource}")
    @current_resource.destroy
    new_resource.updated_by_last_action(true)
    clear_tokens
    node.set['cloud_monitoring']['agent_token']['id'] = nil
    node.set['cloud_monitoring']['agent_token']['token'] = nil
  else
    Chef::Log.debug("#{new_resource} doesn't exist, skipping delete")
    new_resource.updated_by_last_action(false)
  end
end


def load_current_resource
  @current_resource = get_token_by_id node['cloud_monitoring']['agent_token']['id']
  if @current_resource == nil && node['cloud_monitoring']['guess_resource'] == true
    @current_resource = get_token_by_label new_resource.label
    node.set['cloud_monitoring']['agent_token']['id'] = @current_resource.identity unless @current_resource.nil?
    node.set['cloud_monitoring']['agent_token']['token'] = @current_resource.token unless @current_resource.nil?
  end
end
