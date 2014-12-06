require_relative 'master_server_impl'
require 'xmlrpc/server'

def start_server
	$server = XMLRPC::Server.new(50550)
	$server.add_handler('master', MasterServerImpl.new)
	Thread.new{ $server.serve }
end

def shutdown_server
	$server.shutdown
end

