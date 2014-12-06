require_relative 'game_manager_impl'
require_relative 'remote_view_impl' # TODO: no impl
require_relative 'controller_server_impl'
require_relative '../game'

require 'xmlrpc/client'
require 'xmlrpc/server'
require 'socket'

class GameServerImpl < GameManagerImpl
	def initialize(id, player, master)
		@id = id
		@players = [player]
		@master = master

		@game = nil
		@server = XMLRPC::Server.new(port)
		@server.add_handler("game_server", self)
		Thread.new{ @server.serve }
	end

	attr_reader :id

	def ping
		true
	end

	def number_of_players
		@players.length
	end

	def port
		50500 + id
	end

	def shut_down
		@game.quit if game_in_progress
		@server.shutdown
		@master.notify(id)
	end

	def join(player)
		# Not thread-safe.
		if @players.length < 2
			@players << player
			return true
		else
			return false
		end
	end

	def leave(player)
		@players.delete(player)
		shut_down if @players.empty?
		return true
	end

	def start_game(game_options)
	begin
		views = [
			RemoteViewImpl.new(@players[0]),
			RemoteViewImpl.new(@players[1]),
			self
		]

		@game = Game.new(
			game_options,
			*views,
			&get_victory_condition(game_options)
		)

		controllers = [1, 2].map{ |i| ControllerServerImpl.new(@game, i, id) }
		controllers.each{ |c| @game.add_view(c) }

		push_to_client(@players[1], "client.starting_remote_game", game_options, summarize_controller(controllers[1]))
		return summarize_controller(controllers[0])
	rescue Exception => ex
		puts ex.message
		puts ex.backtrace
		raise ex
	end
	end

	def server_owner(player)
		return @players[0] == player
	end

	def summarize_controller(controller)
		{
			"hostname" => Socket.gethostname,
			"port" => controller.port
		}
	end

	def push_to_client(player, command, *args)
		XMLRPC::Client.new(player["hostname"], nil, player["port"]).call(command, *args)
	end

	#TODO: Save and load game will integrate with database.
	#TODO: When game ends, players ranks will be updated.
end

