require_relative 'game_manager_impl' # TODO: no impl

class CLIClient
	def initialize(input_stream=STDIN, output_stream=STDOUT)
		@in = input_stream
		@out = output_stream
		@controller = nil

		@out.puts("Welcome to connect4!")

		loop {
			command = @in.gets.strip
			if command.to_i.to_s == command
				if_game_in_progress{ place_token(command.to_i) }
			elsif command == "start"
				start_game
			elsif command == "quit"
				if_game_in_progress{ end_game }
			elsif command == "exit"
				exit_program
			else
				@out.puts("Invalid command")
			end
		}
	end

	def start_game
		@out.puts("Starting a new game...")
		@controller = GameManagerImpl.start_game(nil)
	end

	def end_game
		GameManagerImpl.end_game
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
		elsif !@controller.my_turn
			@out.puts("It's not your turn!")
		elsif !@controller.game.valid_move(column)
			@out.puts("You can't move there!")
		else
			@controller.play(column)
		end
	end
end
