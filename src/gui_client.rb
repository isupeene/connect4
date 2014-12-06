require 'gtk2'
require_relative "about_dialog"
require_relative "change_master_dialog"
require_relative "join_dialog"
require_relative "load_dialog"
require_relative "leaderboard_dialog"
require_relative "name_dialog"
require_relative "message_dialog"
require_relative "game_manager"
require_relative 'gui_connect4_single_player_view'
require_relative 'gui_connect4_multiplayer_view'
require_relative 'gui_otto_and_toot_single_player_view'
require_relative 'gui_otto_and_toot_multiplayer_view'
require_relative 'implementation/gui_view_server_impl' # TODO: no impl
require_relative 'implementation/remote_controller_impl'
require_relative 'implementation/remote_master_server_impl'
require_relative 'implementation/remote_game_manager_impl'

require 'xmlrpc/client'
require 'xmlrpc/server'
require 'socket'

# Client to play connect 4 or otto and toot through a graphical user interface.
class GUIClient
	@@white = Gdk::Color.parse("#FFFFFF")
	@@game_types = {1 => "Connect 4", 2 => "Otto and Toot"}
	@@default_name = "Player"

	def initialize
		if __FILE__ == $0
			Gtk.init
	
			# Load GUI from a glade file.
			@builder = Gtk::Builder::new
			@builder.add_from_file("implementation/Connect4.glade")
			@builder.connect_signals{ |handler| method(handler) } 
	
			# Quit Gtk when window closed.
			window = @builder.get_object("window1")
			window.signal_connect( "destroy" ) { exit_program }
	      	
			# Set up for new single player game
			menu_option = @builder.get_object("imagemenuitem1")
			menu_option.signal_connect( "activate" ) { set_up_board({"single_player" => true}) }
	      	
			# Set up for new 2 player game
			menu_option = @builder.get_object("imagemenuitem2")
			menu_option.signal_connect( "activate" ) { set_up_board }
				
			# Set up for joining server 2 player game
			menu_option = @builder.get_object("joinmenuitem")
			menu_option.signal_connect( "activate" ) { join_server }
			
			# Set up for leaving server 2 player game
			menu_option = @builder.get_object("leavemenuitem")
			menu_option.signal_connect( "activate" ) { leave_server }

			# Set up Open in menu to load game
			menu_option = @builder.get_object("imagemenuitem3")
			menu_option.signal_connect( "activate" ) { load_game }
	      	
			# Set up Save in menu to save game
			menu_option = @builder.get_object("imagemenuitem4")
			menu_option.signal_connect( "activate" ) { save_game }
	      	
			# Set up Save as for saving game
			menu_option = @builder.get_object("imagemenuitem5")
			menu_option.signal_connect( "activate" ) { save_game_as }
	
			# Set up Quit menu option
			menu_option = @builder.get_object("imagemenuitem6")
			menu_option.signal_connect( "activate" ) { exit_program }
				
			# Set up Player name change menu option
			menu_option = @builder.get_object("namemenuitem")
			menu_option.signal_connect( "activate" ) { name_entry }
				
			# Set up for changing master server
			menu_option = @builder.get_object("changemastermenuitem")
			menu_option.signal_connect( "activate" ) { set_master }
				
			# Set up About menu option
			menu_option = @builder.get_object("aboutmenuitem")
			menu_option.signal_connect( "activate" ) { about }	
	      	
			# Set up option for game type
			1.upto(2) { |i|
				menu_option = @builder.get_object("checkmenuitem" + i.to_s)
				menu_option.signal_connect( "activate" ) { game_type(i) }
			}
			
			# Set up leaderboard options
			1.upto(2) { |i|
				menu_option = @builder.get_object("leaderboardmenuitem" + i.to_s)
				menu_option.signal_connect( "activate" ) { leaderboard(i) }
			}
			
			# Activate a game type for default.
			menu_option = @builder.get_object("checkmenuitem" + 1.to_s)
			menu_option.set_active true
			
			@about_dialog = AboutDialog.new
			@message_dialog = MessageDialog.new
			@leaderboard_dialog = LeaderboardDialog.new
			@load_dialog = LoadDialog.new
			@name_dialog = NameDialog.new
			@join_dialog = JoinDialog.new
			@change_master_dialog = ChangeMasterDialog.new
			@player_names = ["","Player 2"]
			name_entry
	      	
			# Set up signals for button clicks and store the buttons to give to the views.
			@buttons = Array.new(6){Array.new(7)}
			0.upto(5) { |i|
				0.upto(6) { |j|
					@buttons[i][j] = @builder.get_object("buttoni" + i.to_s + "j" +j.to_s)
					@buttons[i][j].signal_connect("clicked"){button_clicked(j)}
				}
			}
			
			# Get displays for the client and views to write to.
			@client_display = @builder.get_object("label1")
			@view_displays = []
			2.upto(4) { |i|
				@view_displays << @builder.get_object("label" + i.to_s)
			}
			@controllers = nil
			@game_manager = GameManager.new
			@master_server = nil
			real_set_master("localhost") # TEMP: for testing
			@remote_view = GUIViewServerImpl.new(@buttons, @view_displays)
			
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
					@message_dialog.run(
						"Ports 50530 to 50549 are busy.  Online play will be disabled for this session."
					)
					@view_server = nil
				end
			end
		
	
			window.show()
			begin
				Gtk.main()
			ensure
				leave_server if connected_to_game_server
			end
		end
	end
	
	def exit_program
		leave_server if @game_server
		@view_server.shutdown if @view_server
		Gtk.main_quit
	end
	
	def connected_to_game_server
		# Kind of a hack? Maybe check for GameServerContract instead.
		@game_manager.is_a?(RemoteGameManagerImpl)
 	end
	
	def join_server 
		if_connected_to_master{
			server_list = @master_server.server_list
			server_number = @join_dialog.run(server_list)
			server = server_list.find{ |s| s["id"] == server_number }
			if !server
				@message_dialog.puts("This server was not found.")
			elsif server["number_of_players"] == 2
				@message_dialog.puts("This server is already full.")
			else 
				# TODO: fix race condition (check if join succeeds)
				leave_server if connected_to_game_server
				@game_manager = RemoteGameManagerImpl.new(server)
				@game_manager.join(get_player_object)
			end
		}
	end
	
	def leave_server
		if_connected_to_game_server{
			@game_manager.leave(get_player_object)
			@game_manager = GameManager.new
		}
	end
	
	def get_player_object
		{
			# TODO: correct values
			"username" => "isupeene",
			"port" => @port,
			"hostname" => "localhost"
		}
	end
	
	def real_set_master(hostname="")
		unless hostname.empty?
			@master_server = RemoteMasterServerImpl.new({
				"hostname" => hostname,
				"port" => 50550
			})
		end
	end
	
	def set_master(hostname="")
		if_online{
			unless hostname.empty?
				hostname = @change_master_dialog.run
			end
			real_set_master(hostname)
		}
	end
	
	def end_game
		@game_manager.end_game
	end
	
	def open_server
		connection_info = @master_server.open_server(get_player_object)
		if connection_info
			leave_server if @game_server
			# TODO: No localhost
			@game_manager = RemoteGameManagerImpl.new(connection_info)
		elsif
			@message_dialog.run("Attempt to open server failed.")
		end
	end
	
	# Clear board back to its original state, all blank, white buttons
	def clear_board
		@buttons.each{ |row|
			row.each { |button|
				button.set_label("")
				button.modify_bg(Gtk::STATE_NORMAL, @@white)
			}
		}
	end
	
	def if_online
		if @view_server
			yield
		else
			@message_dialog.run("Not available in offline mode.")
		end
	end
	
	# Perform block if a game is in progress.
 	def if_game_in_progress
		if game_in_progress
 			yield
 		else
			@message_dialog.run("There's currently no game in progress!")
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
			yield
		else
			@out.puts("You're not connected to the master server!")
		end
	end
	
	def if_connected_to_game_server
		if connected_to_game_server
			yield
		else
			@out.puts("You're not connected to a game server!")
		end
	end

	# Set up board based on game options and game type.
	# Create an appropriate view for the game 
	def set_up_board(options={})
		end_game if game_in_progress
		clear_board
		@current_game_type = @next_game_type
		if @next_game_type == 2
			options["otto_and_toot"] = true
			@remote_view.set_otto_and_toot
		else
			@remote_view.set_connect4
		end
		
		# Start new server if multiplayer game
		if !options["single_player"]
			if_connected_to_master{ open_server }
		end
		
		if connected_to_game_server
			if_server_owner {
				@remote_view.set_player_number(1)
				@controllers = @game_manager.start_game(options)
			}
		else
			@controllers = @game_manager.start_game(options, get_view(options))

		end
		
		@client_display.set_label("#{@@game_types[@current_game_type]} game.")
	end
	
	def starting_remote_game(game_options, controller)
		begin
			if game_options["otto_and_toot"]
				@current_game_type = 2
				@remote_view.set_otto_and_toot
			else
				@current_game_type = 1
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
	
	# Returns an appropriate view for the game based on the options.
	def get_view(options)
		if options["single_player"]
			if options["otto_and_toot"]
				GUIOttoAndTootSinglePlayerView.new(@buttons, @view_displays, 1)
			else
				GUIConnect4SinglePlayerView.new(@buttons, @view_displays, 1)
			end
		else
			if options["otto_and_toot"]
				GUIOttoAndTootMultiplayerView.new(@buttons, @view_displays)
			else
				GUIConnect4MultiplayerView.new(@buttons, @view_displays)
			end
		end
	end

	# Validates move and plays the move if it is valid.
	def button_clicked(column)
		if !game_in_progress
			@client_display.set_label("There is no game in progress!")
		elsif !my_turn
			@client_display.set_label("It's not your turn!")
		elsif !current_controller.valid_move(column)
			@client_display.set_label("You can't play there!")
		else
			current_controller.play(column)
		end
	end
	
	# Get controller for current turn.
	def current_controller
		[*@controllers].select{|c| c.my_turn }[0] if @controllers
	end
	
	# Determine if it is a user's turn
	def my_turn
		!current_controller.nil?
	end
	
	# TODO Use player names in view instead of default. Need to get 2nd player name
	# from server.
	def name_entry
		@player_names[0] = @name_dialog.run(@player_names[0], @@default_name)
	end
	
	def about
		@about_dialog.run
	end
	
	# TODO interface with backend. Get different stats for different game types.
	def leaderboard(chosen_type)
		if_connected_to_master{
			rankings = @master_server.leaderboards(chosen_type)
			@leaderboard_dialog.run(@@game_types[chosen_type], rankings)
		}
	end
	
	# Load game into client
	# TODO interface with backend when done to display game ids
	# and load game.
	def load_game
		
		id = @load_dialog.run(1..100)
		
		# Leaving these comments for program flow notes for interfacing.
		
		#if !@game_manager.save_file_present
		#	@client_display.set_label("There is no game file to load.")
		#elsif !@controllers = @game_manager.load_game
		#	@client_display.set_label("An error occurred while loading.")
		#else
		#	clear_board
		#	options = @game_manager.get_options
	#	
	#		if options["otto_and_toot"]
	#			@current_game_type = 2
	#		else
	#			@current_game_type = 1
	#		end
	#		@game_manager.add_view(get_view(options))
	#		@client_display.set_label("#{@@game_types[@current_game_type]} game.")
	#	end
	end
	
	# Save game to disk
	def save_game
		if @game_manager.save_game
			@client_display.set_label("Game saved successfully.")
			@message_dialog.run("Game saved successfully.")
		else
			@client_display.set_label("Error occurred while saving.")
		end
	end
	
	# Save game to disk
	def save_game_as
		save_game
	end
	
	# Set up next game type to and make sure there is only one game type checked in the GUI
	def game_type(chosen_type)
		menu_option = @builder.get_object("checkmenuitem" + chosen_type.to_s)
		if menu_option.active? && @next_game_type != chosen_type
			@next_game_type = chosen_type
			menu_option = @builder.get_object("checkmenuitem" + (3 - chosen_type).to_s)
			menu_option.set_active false
		elsif !menu_option.active? && @next_game_type == chosen_type
			@next_game_type = 3 - chosen_type
			menu_option = @builder.get_object("checkmenuitem" + (3 - chosen_type).to_s)
			menu_option.set_active true
		end
	end
	
end

GUIClient.new

