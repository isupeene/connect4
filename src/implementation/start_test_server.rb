require_relative 'master_server_impl'
require 'xmlrpc/server'

def start_server
	$server = MasterServerImpl.new
end

def shutdown_server
	$server.shutdown
end

