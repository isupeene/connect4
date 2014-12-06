require 'xmlrpc/client'

class Client
	def initialize(connection_info)
		@connection_info = connection_info
	end

	def client
		# TODO: No localhost
		XMLRPC::Client.new("localhost", nil, @connection_info["port"])
	end

	def ping
		begin
			client.call("game_server.ping")
		rescue Exception
			return false
		end
	end

	def method_missing(symbol, *args)
		client.call(target + "." + symbol.to_s, *args)
	end

	def to_a
		[self]
	end
end

