
require 'gtk2'
#TODO No impl
require_relative "game_manager_impl"

class GUIViewImpl

	@@white = "#FFFFFF"
	@@black = "#000000"
	@@red = "#FF0000"
	@@game_types = {1 => "Connect 4", 2 => "Otto and Toot"}

	def initialize
		if __FILE__ == $0
			Gtk.init
	
			@builder = Gtk::Builder::new
			@builder.add_from_file("Connect4.glade")
			@builder.connect_signals{ |handler| method(handler) } 
	
			# Quit Gtk when window closed.
			window = @builder.get_object("window1")
			window.signal_connect( "destroy" ) { Gtk.main_quit }
	      	
			# Set up for new single player game
			menu_option = @builder.get_object("imagemenuitem1")
			menu_option.signal_connect( "activate" ) { set_up_board({:single_player => true}) }
	      	
			# Set up for new 2 player game
			menu_option = @builder.get_object("imagemenuitem2")
			menu_option.signal_connect( "activate" ) { set_up_board }
	      	
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
			menu_option.signal_connect( "activate" ) { Gtk.main_quit }
	      	
			# Set up option for game type
			1.upto(2) { |i|
				menu_option = @builder.get_object("checkmenuitem" + i.to_s)
				menu_option.signal_connect( "activate" ) { game_type(i) }
			}
			
			# Activate a game type for default.
			menu_option = @builder.get_object("checkmenuitem" + 1.to_s)
			menu_option.set_active true
	      	
			# Set up signals for button clicks
			0.upto(5) { |i|
				0.upto(6) { |j|
					button = @builder.get_object("buttoni" + i.to_s + "j" +j.to_s)
					button.signal_connect("clicked"){button_clicked(j)}
				}
			}
			@display = @builder.get_object("label1")
			@controllers = nil
			# This will cause the first game type to be checked in the GUI
			
			set_up_board
	
			window.show()
			Gtk.main()
			
		end
	end
  
	def clear_board
		color = Gdk::Color.parse(@@white)
		0.upto(5) { |i|
			0.upto(6) { |j|
				button = @builder.get_object("buttoni" + i.to_s + "j" +j.to_s)
				button.set_label("")
				button.modify_bg(Gtk::STATE_NORMAL, color)
				button.modify_fg(Gtk::STATE_NORMAL, color)
			}
		}
	end


	def set_up_board(game_options={})
		clear_board
		#TODO Properly integrate
		game_options[:view] = self
		@controllers = GameManagerImpl.start_game(game_options)
		@current_game_type = @next_game_type
		@display.set_label("New #{@@game_types[@current_game_type]} game. Player 1's turn.")
	end

	def button_clicked(column)
		error_message = nil
		if !GameManagerImpl.game_in_progress
			@display.set_label("There is no game in progress!")
		elsif !my_turn
			error_message = "It's not your turn!"
		elsif !current_controller.game.valid_move(column)
			error_message = "You can't play there!"
		else
			current_controller.play(column)
		end
		
		unless error_message.nil?
			if !my_turn
				@display.set_label("#{error_message} AI's turn.")
			else
				@display.set_label("#{error_message} Player #{current_controller.player_number}'s turn.")
			end
		end
	end
	
	def current_controller
		[*@controllers].select{|c| c.my_turn }[0] if @controllers
	end
	
	def my_turn
		!current_controller.nil?
	end
	
	def load_game
		#TODO Load constantly fails
		if !GameManagerImpl.save_file_present
			@display.set_label("There is not game file to load.")
		elsif !@controllers = GameManagerImpl.load_game
			@display.set_label("An error occurred while loading.")
		else
			#TODO Determine game type from save file.
			@current_game_type = @next_game_type
		end	
	end
	
	def save_game
		if GameManagerImpl.save_game
			@display.set_label("Game saved successfully.")
		else
			@display.set_label("Error occurred while saving.")
		end
	end
	
	def save_game_as
		save_game
	end
	
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
	
	def each_set_button(board)
		blank = Gdk::Color.parse(@@white)
		board.each_with_index{ |x,i,j|
			button = @builder.get_object("buttoni" + i.to_s + "j" +j.to_s)
			if x.nil?
				button.set_label("")
				button.modify_bg(Gtk::STATE_NORMAL, blank)
				button.modify_fg(Gtk::STATE_NORMAL, blank)
			else
				yield button, x
			end
		}
				
	end
	
	def connect4_update(board)
		red = Gdk::Color.parse(@@red)
		black = Gdk::Color.parse(@@black)
		each_set_button(board){ |button, x|
			if x == 1
				button.modify_bg(Gtk::STATE_NORMAL, red)
				button.modify_fg(Gtk::STATE_NORMAL, red)
			elsif x == 2
				button.modify_bg(Gtk::STATE_NORMAL, black)
				button.modify_fg(Gtk::STATE_NORMAL, black)
			end
		}
	end
	
	def otto_and_toot_update(board)
		each_set_button(board){ |button, x|
			if x == 1
				button.set_label("O")
			elsif x == 2
				button.set_label("T")
			end
		}
	end
	
	def turn_update(update)
		puts "JIMMY"
		if update[:board]
			case @current_game_type
			when 1
				connect4_update(update[:board])
			when 2
				otto_and_toot_update(update[:board])
			end
		end
		
		if update[:game_over]
			game_over(update[:winner])
		elsif update[:current_turn]
			if my_turn
				@display.set_label("Player #{current_controller.player_number}'s turn.")
			else 
				@display.set_label("AI's turn.")
			end
		end
	end
	
	def game_over(winner)
		case winner
		when 0
			@display.set_label("Tie game!")
		when 1..2
			ai_wins = true
			[*@controllers].each { |c|
				if c.player_number == winner
					@display.set_label("Player #{c.player_number} wins.")
					ai_wins = false
				end
			}
			if ai_wins
				@display.set_label("AI wins.")
			end
		end
	end
end


GUIViewImpl.new