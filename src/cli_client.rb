require_relative 'game_manager' 
require_relative 'cli_connect4_single_player_view'
require_relative 'cli_connect4_multiplayer_view'
require_relative 'cli_otto_and_toot_single_player_view'
require_relative 'cli_otto_and_toot_multiplayer_view'
require_relative 'implementation/cli_view_server_impl' # TODO: no impl
require_relative 'implementation/remote_controller_impl'
require_relative 'implementation/remote_master_server_impl'
require_relative 'implementation/remote_game_manager_impl'

require 'xmlrpc/client'
require 'xmlrpc/server'
require 'socket'

# Command line interface client to play connect 4 and otto and toot.
# Can be run by requiring this file and then creating a new instance.
class CLIClient
	# Initialize client with input and output streams.
	def initialize(input_stream=STDIN, output_stream=STDOUT)
		@in = input_stream
		@out = output_stream
		@controllers = nil
		@game_manager = GameManager.new
		@master_server = nil
		set_master("localhost") # TEMP: for testing
		@remote_view = CLIViewServerImpl.new(@out)

		@port = 50530
		begin
			@view_server = XMLRPC::Server.new(@port)
			@view_server.add_handler("view", @remote_view)
			@view_server.add_handler("client", self)
			Thread.new{ @view_server.serve }
		rescue Errno::EADDRINUSE
			@port += 1
			if @port < 50550
				retry
			else
				@out.puts(
					"Ports 50530 to 50549 are busy.  Online play will be disabled for this session."
				)
				@view_server = nil
			end
		end

		@out.puts("Welcome to connect4!")

		# Loop to get user input. valid commands are the words below and numbers
		begin
		loop {
			input = @in.gets.strip
			if input == ""
				command = ""
			else
				input_line = input.split
				command = input_line.shift.strip
			end

			if command.to_i.to_s == command
				if_game_in_progress{ place_token(command.to_i) }
			elsif command == "start"
				start_game(input_line)
			elsif command == "save"
				save_game
			elsif command == "list-saved-games"
				if_connected_to_game_server{ list_saved_games }
			elsif command == "load"
				load_game(input_line)
			elsif command == "show-leaderboards"
				if_connected_to_master{ show_leaderboards }
			elsif command == "list-servers"
				if_connected_to_master{ list_servers }
			elsif command == "open-server"
				if_connected_to_master{ open_server }
			elsif command == "join-server"
				if_connected_to_master{ join_server(input_line[0]) }
			elsif command == "leave-server"
				if_connected_to_game_server{ leave_server }
			elsif command == "set-master"
				if_online{ set_master(input_line[0]) }
			elsif command == "quit"
				if_game_in_progress{ end_game }
			elsif command == "exit"
				exit_program
			else
				@out.puts("Invalid command")
			end
		}
		ensure
			leave_server if connected_to_game_server
		end
	end

	def connected_to_game_server
		# Kind of a hack? Maybe check for GameServerContract instead.
		@game_manager.is_a?(RemoteGameManagerImpl)
	end

	# Start a new game based on the start command. -s means single player
	# and -o means otto_and_toot
	def start_game(input_line)
		end_game if game_in_progress

		options = {}
		if input_line.include?("-s")
			options["single_player"] = true
		end
		if input_line.include?("-o")
			options["otto_and_toot"] = true
			@remote_view.set_otto_and_toot
		else
			@remote_view.set_connect4
		end
		@out.puts("Starting a new game...")
		if connected_to_game_server
			if_server_owner {
				@remote_view.set_player_number(1)
				@controllers = @game_manager.start_game(options)
			}
		else
			@controllers = @game_manager.start_game(options, get_view(options))
		end
	end

	def starting_remote_game(game_options, controller)
	begin
		if game_options["otto_and_toot"]
			@remote_view.set_otto_and_toot
		else
			@remote_view.set_connect4
		end
		@remote_view.set_player_number(2)
		@controllers = RemoteControllerImpl.new(controller)
	rescue Exception => ex
		puts ex.message
		puts ex.backtrace
		raise ex
	end
	return true
	end

	# Generate an appropriate view based on the options.
	def get_view(options)
		if options["single_player"]
			if options["otto_and_toot"]
				CLIOttoAndTootSinglePlayerView.new(@out, 1)
			else
				CLIConnect4SinglePlayerView.new(@out, 1)
			end
		else
			if options["otto_and_toot"]
				CLIOttoAndTootMultiplayerView.new(@out)
			else
				CLIConnect4MultiplayerView.new(@out)
			end
		end
	end

	def list_servers
		# TODO: Formatting
		@out.puts("#{@master_server.server_list}")
	end

	def open_server
		connection_info = @master_server.open_server(get_player_object)
		if connection_info
			leave_server if @game_server
			# TODO: No localhost
			@game_manager = RemoteGameManagerImpl.new(connection_info)
		elsif
			@out.puts("Attempt to open server failed.")
		end
	end

	def join_server(server_number)
		server_list = @master_server.server_list
		server = server_list.find{ |s| s["id"] == server_number.to_i }
		if !server
			@out.puts("This server was not found.")
		elsif server["number_of_players"] == 2
			@out.puts("This server is already full.")
		else 
			# TODO: fix race condition (check if join succeeds)
			leave_server if connected_to_game_server
			@game_manager = RemoteGameManagerImpl.new(server)
			@game_manager.join(get_player_object)
		end
	end

	def leave_server
		@game_manager.leave(get_player_object)
		@game_manager = GameManager.new
	end

	def get_player_object
		{
			# TODO: correct values
			"username" => "isupeene",
			"port" => @port,
			"hostname" => "localhost"
		}
	end

	def set_master(hostname)
		master = RemoteMasterServerImpl.new({
			"hostname" => hostname,
			"port" => 50550
		})
		if master.ping
			@master_server = master
		else
			puts "Could not connect to master server."
		end
	end

	# End current game.
	def end_game
		@game_manager.end_game
	end

	# Save current game.
	def save_game
		if @game_manager.save_game
			@out.puts("Saved!")
		else
			@out.puts("An error occurred while saving.")
		end
	end

	def list_saved_games
		@out.puts(@game_manager.saved_games)
	end

	def show_leaderboards
		@out.puts(@master_server.leaderboards)
	end

	# Load saved game if there is one.
	def load_game(input_line)
		if connected_to_game_server
			id = input_line[0].to_i
			saved_game = @game_manager.saved_games.find{ |g| g["id"] == id }
			if saved_game
				connection_info = @game_manager.load_game(id)
				if connection_info
					@controllers = RemoteControllerImpl.new(connection_info)
					if saved_game["otto_and_toot"]
						@remote_view.set_otto_and_toot
					else
						@remote_view.set_connect4
					end
					@remote_view.set_player_number(1)
				else
					@out.puts("An error occured while loading.")
				end
			else
				@out.puts("No save game exists with this id.")
			end
		else
			if !@game_manager.save_file_present
				@out.puts("No save file is available to load.")
			elsif !@controllers = @game_manager.load_game
				@out.puts("An error occurred while loading.")
			else
				options = @game_manager.get_options
				@game_manager.add_view(get_view(options))
			end
			@remote_view.deactivate
		end
	end

	def if_online
		if @view_server
			yield
		else
			@out.puts("Not available in offline mode.")
		end
	end

	# Perform block if a game is in progress.
	def if_game_in_progress
		if game_in_progress
			yield
		else
			@out.puts("There's currently no game in progress!")
		end
	end

	def game_in_progress
		@game_manager.game_in_progress
	end

	def server_owner
		# Every place where we check the type of game manager is kind of a hack.
		!connected_to_game_server || @game_manager.server_owner(get_player_object)
	end

	def if_server_owner
		if_connected_to_game_server{
			if server_owner
				yield
			else
				@out.puts("Only the server owner can do that!")
			end
		}
	end

	def if_connected_to_master
		if @master_server
			begin
				yield
			rescue Exception => ex
				@out.puts(
					"An error occurred communicating " \
					"with the master server.\n" \
					"You have been disconnected."
				)
				@master_server = nil
				@game_manager = GameManager.new if connected_to_game_server
			end
		else
			@out.puts("You're not connected to the master server!")
		end
	end

	def if_connected_to_game_server
		if connected_to_game_server
			begin
				yield
			rescue Exception => ex
				@out.puts(
					"An error occurred communicating " \
					"with the game server.\n" \
					"You have been disconnected."
				)
				@game_manager = GameManager.new
			end
		else
			@out.puts("You're not connected to a game server!")
		end
	end

	# Exit the client.
	def exit_program
		@out.puts("See you again! Hah hah hah hah hah hah!")
		leave_server if @game_server
		@view_server.shutdown if @view_server
		exit
	end

	# Place a token in the column if valid. Otherwise provide error message.
	def place_token(column)
		if !game_in_progress
			@out.puts("There is no current game in progress!")
		elsif !my_turn
			@out.puts("It's not your turn!")
		elsif !current_controller.valid_move(column)
			@out.puts("You can't move there!")
		else
			current_controller.play(column)
		end
	end

	# Get controller for player who's turn it is currently.
	def current_controller
		[*@controllers].select{|c| c.my_turn }[0] if @controllers
	end

	# Determine if it is the client's turn to play.
	def my_turn
		!current_controller.nil?
	end
end

