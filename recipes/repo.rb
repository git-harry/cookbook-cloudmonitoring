platform_options = node['cloud_monitoring']['platform']
if platform_family?("debian")
  apt_repository "cloud-monitoring" do
    uri platform_options['repo_uri']
    distribution "cloudmonitoring"
    components ["main"]
    key platform_options['repo_key']
    action :add
    notifies :run, 'execute[apt-get update]', :immediately
  end
elsif platform_family?("rhel")
  yum_key "Rackspace-Monitoring" do
    url platform_options['repo_key']
    action :add
  end

  yum_repository "cloud-monitoring" do
    description "Rackspace Monitoring"
    url platform_options['repo_uri']
    action :add
  end
else
  msg = "The platform family #{node[platform_family]} is unsupported."
  Chef::Application.fatal!(msg, 1)
end
