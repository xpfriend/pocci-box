require 'serverspec'
require 'pathname'
require 'net/ssh'

base_spec_dir = Pathname.new(File.join(File.dirname(__FILE__), '..'))
Dir[base_spec_dir.join('shared/**/*.rb')].sort.each{ |f| require f }


set :backend, :ssh

if ENV['ASK_SUDO_PASSWORD']
  begin
    require 'highline/import'
  rescue LoadError
    fail "highline is not available. Try installing it."
  end
  set :sudo_password, ask("Enter sudo password: ") { |q| q.echo = false }
else
  set :sudo_password, ENV['SUDO_PASSWORD']
end

host = ENV['TARGET_HOST']

options = {}
options[:host_name] = '127.0.0.1'
options[:user] = 'pocci'
options[:keys] = base_spec_dir.join('spec', host, '.vagrant/machines/default/virtualbox/private_key')
options[:paranoid] = false

set :host,        options[:host_name] || host
set :ssh_options, options
set :sudo_options, '-i'


# Disable sudo
# set :disable_sudo, true


# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C' 

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'
