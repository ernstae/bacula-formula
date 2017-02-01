# This is required due to the following bug in vagrant:
# https://github.com/mitchellh/vagrant/issues/5186
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.insert_key = false
end
