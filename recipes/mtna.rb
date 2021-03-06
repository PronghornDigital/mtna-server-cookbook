#
# Cookbook Name::mtna_server
# Recipe::mtna
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

# default mtna data directory
directory '/var/archives/data' do
  owner 'root'
  group 'mtna'
  mode '0775'
  action :create
end

# default mtna incoming video directory
directory '/var/archives/incoming' do
  owner 'root'
  group 'mtna'
  mode '0775'
  action :create
end

# ensure that the .db.json at least exists
file '/var/archives/data/.db.json' do
  content '{}'
  mode '0775'
  owner 'root'
  group 'mtna'
  action :create_if_missing
end

# ensure perms are correct always
file '/var/archives/data/.db.json' do
  mode '0775'
  owner 'root'
  group 'mtna'
end

# before we install the new version, let's backup
bash 'mtna-preinstall-backup' do
  code '/opt/PronghornDigital/mtna-server-cookbook/backup.sh -mtna-chef-preinstall'
  ignore_failure false
end

# install the mtna rpm
# TODO: Use package - currently package doesn't support dnf and the dnf cookbook is broken.
bash 'mtna' do
  code <<-EOH
    dnf install -y $(gh latest PronghornDigital/mtna-server-cookbook --download-url)
    EOH
  ignore_failure false
end

# install the systemd service file that runs mtna
template '/etc/systemd/system/mtna.service' do
  mode '0755'
  source 'mtna.service.erb'
  notifies :restart, 'service[mtna.service]', :delayed
end

service 'mtna.service' do
  reload_command 'systemctl daemon-reload'
  action %i[start enable]
end
