require 'test/unit'
require 'xmlrpc'

module MasterServerContract
	def new_game_precondition(game_options)
		assert(server_list.count < 10, "There can be only 10.")
	end
	
	def new_game_postcondition(game_options, result)
		assert(
			XMLRPC::Client.new("127.0.0.1:#{result}").call(:ping),
			"A game server should be running at the specified port."
		)
		assert(
			server_list.any?{ |server| server.port == result },
			"The new server should be in the server list."
		)
	end
	
	# The master server will provide access to the database, but it's
	# unnecessary to duplicate the database contracts here.
end