require 'xmlrpc/server'
require_relative "controller_impl"

class ControllerServerImpl < ControllerImpl
	def initialize(game, player_number, server_number)
		super(game, player_number)
		@server_number = server_number
		@server = XMLRPC::Server.new(port)
		@server.add_handler("controller", self)
		Thread.new{ @server.serve }
	end

	def port
		50500 + 10*@player_number + @server_number
	end

	def turn_update(update)
		@server.shutdown if update["game_over"]
	end
end

