require 'serverspec'

details = {}

if RUBY_PLATFORM =~ /(win|mswin|mingw)/i
  set :backend, :cmd
  set :os, :family => 'windows'
  details = {
    check_owner:      false,
    config:           "c:\\Program Files (x86)\\Instrumental Tools\\etc\\instrumental.yml",
    has_pid:          false,
    service_name:     "Instrument Server"
  }
else
  set :backend, :exec
  details = {
    check_owner:      true,
    config:           "/etc/instrumental.yml",
    has_pid:          true,
    pid_path:         "/opt/instrumental-tools/instrument_server.pid",
    owner:            "nobody",
    service_name:     "instrument_server"
  }
end

describe service(details[:service_name]) do
  it { should be_enabled }
  it { should be_running }
end

if details[:has_pid]
  describe file(details[:pid_path]) do
    it { should be_file }
    if details[:check_owner]
      it { should be_owned_by(details[:owner]) }
    end
  end
end

describe file(details[:config]) do
  it { should be_file }
  if details[:check_owner]
    it { should be_owned_by(details[:owner]) }
  end
end
