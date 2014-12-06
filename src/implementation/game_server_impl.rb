require_relative 'game_manager_impl'
require_relative 'remote_view_impl' # TODO: no impl
require_relative 'controller_server_impl'
require_relative 'database_manager_impl'
require_relative '../game'

require 'xmlrpc/client'
require 'xmlrpc/server'
require 'socket'

class GameServerImpl < GameManagerImpl
	def initialize(id, player, master)
		@id = id
		@players = [player]
		@master = master
		@database = DatabaseManagerImpl.new

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

	def shutdown
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
		@game.quit if game_in_progress
		shutdown if @players.empty?
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

		game_options.delete("board") # HACK
		push_to_client(@players[1], "client.starting_remote_game", game_options, summarize_controller(controllers[1]))
		return summarize_controller(controllers[0])
	rescue Exception => ex
		puts ex.message
		puts ex.backtrace
		raise ex
	end
	end

	def save_game
		@database.save_game(@game)
	end

	def saved_games
		@database.saved_games
	end

	def saved_game_ids
		@database.saved_game_ids
	end

	def load_game(id)
		game_options = @database.load_game
		if game_options
			start_game(game_options)
		else
			return false
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

