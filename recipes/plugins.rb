include_recipe 'cloud_monitoring::agent'

directory node['cloud_monitoring']['plugin_path'] do
  recursive true
  action :delete
end

platform_options = node['cloud_monitoring']['platform']
node['cloud_monitoring']['plugins'].each_pair do |source_cookbook, source_dir|
  remote_directory "cloud_monitoring_plugins_#{source_cookbook}" do
    path node['cloud_monitoring']['plugin_path']
    cookbook source_cookbook
    source source_dir
    files_mode 0755
    owner 'root'
    group 'root'
    mode 0755
    recursive true
    purge false
    notifies :restart, "service[#{platform_options['service']}]", :delayed
  end
end
