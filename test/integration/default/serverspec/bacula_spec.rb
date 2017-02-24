require 'serverspec'

set :backend, :exec

## Sample serverspec stuff, see http://serverspec.org/resource_types.html for full docs

describe package('bacula-common') do
  it { should be_installed }
end

describe package('bacula-common-pgsql') do
  it { should be_installed }
end

describe package('bacula-director-common') do
  it { should be_installed }
end

describe package('bacula-director-pgsql') do
  it { should be_installed }
end

describe package('bacula-console') do
  it { should be_installed }
end

describe file('/etc/bacula') do
  it { should be_directory }
end

describe file('/etc/bacula/bacula-dir.conf') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should contain 'Director {' }
end
