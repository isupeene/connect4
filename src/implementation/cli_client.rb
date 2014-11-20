require_relative 'game_manager_impl' # TODO: no impl
require_relative 'cli_connect4_single_player_view_impl'
require_relative 'cli_connect4_multiplayer_view_impl'

class CLIClient
	def initialize(input_stream=STDIN, output_stream=STDOUT)
		@in = input_stream
		@out = output_stream
		@controllers = nil

		@out.puts("Welcome to connect4!")

		loop {
			input_line = @in.gets.strip.split
			command = input_line.shift.strip

			if command.to_i.to_s == command
				if_game_in_progress{ place_token(command.to_i) }
			elsif command == "start"
				start_game(input_line)
			elsif command == "save"
				save_game
			elsif command == "load"
				load_game
			elsif command == "quit"
				if_game_in_progress{ end_game }
			elsif command == "exit"
				exit_program
			else
				@out.puts("Invalid command")
			end
		}
	end

	def start_game(input_line)
		options = {}
		if input_line.include?("-s")
			options[:single_player] = true
		end
		@out.puts("Starting a new game...")
		@controllers = GameManagerImpl.start_game(options, get_view(options))
	end

	def get_view(options)
		if options[:single_player]
			CLIConnect4SinglePlayerViewImpl.new(@out, 1)
		else
			CLIConnect4MultiplayerViewImpl.new(@out)
		end
	end

	def end_game
		GameManagerImpl.end_game
	end

	def save_game
		if GameManagerImpl.save_game
			@out.puts("Saved!")
		else
			@out.puts("An error occurred while saving.")
		end
	end

	def load_game
		if !GameManagerImpl.save_file_present
			@out.puts("No save file is available to load.")
		elsif !@controllers = GameManagerImpl.load_game
			@out.puts("An error occurred while loading.")
		end
	end

	def if_game_in_progress
		if GameManagerImpl.game_in_progress
			yield
		else
			@out.puts("There's currently no game in progress!")
		end
	end

	def exit_program
		@out.puts("See you again! Hah hah hah hah hah hah!")
		exit
	end

	def place_token(column)
		if !GameManagerImpl.game_in_progress
			@out.puts("There is no current game in progress!")
		elsif !my_turn
			@out.puts("It's not your turn!")
		elsif !current_controller.game.valid_move(column)
			@out.puts("You can't move there!")
		else
			current_controller.play(column)
		end
	end

	def current_controller
		[*@controllers].select{|c| c.my_turn }[0] if @controllers
	end

	def my_turn
		!current_controller.nil?
	end
end

