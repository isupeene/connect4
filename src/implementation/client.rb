require 'xmlrpc/client'

class Client
	# When left for too long, the XMLRPC::Client will become invalid,
	# and you'll get a broken pipe error.  So, we need to refresh the client
	# once in a while.  However, the server can only handle so many
	# connections at once (like, 4, or something stupid like that), so
	# if we create too many clients too quickly, the last one will timeout.
	# To rectify this, we use the same client if we're sure it hasn't timed
	# out, and otherwise, we refresh the client.
	#
	# 5 seconds is arbitrary - I think the actual timeout is more like
	# 30 seconds.  If this turns out to be a problem, we can tweak this.
	TIMEOUT = 15

	def initialize(connection_info)
		@connection_info = connection_info
		@last_used = Time.now - TIMEOUT
	end

	def client
		if Time.now - @last_used > TIMEOUT
			# TODO: No localhost
			@cached_client = XMLRPC::Client.new("localhost", nil, @connection_info["port"])
		end
		@last_used = Time.now
		return @cached_client
	end

	def ping
		begin
			client.call(target + "." + "ping")
		rescue Exception
			return false
		end
	end

	def method_missing(symbol, *args)
		#puts "Calling #{target}.#{symbol}"
		result = client.call(target + "." + symbol.to_s, *args)
		#puts "Returned from #{target}.#{symbol}"
		return result
	end

	def to_a
		[self]
	end
end

