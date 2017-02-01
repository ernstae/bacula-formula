require 'serverspec'

set :backend, :exec

## Sample serverspec stuff, see http://serverspec.org/resource_types.html for full docs

#describe package('apt-mirror') do
#  it { should be_installed }
#end

#describe user('apt-mirror') do
#  it { should exist }
#end

#describe file('/srv/aptmirror') do
#  it { should be_directory }
#end

#describe file('/etc/apt/mirror.list') do
#  it { should be_file }
#  it { should be_mode 644 }
#  it { should be_owned_by 'root' }
#  it { should be_readable.by_user('apt-mirror') }
#  it { should contain 'deb-amd64 http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main' }
#end
