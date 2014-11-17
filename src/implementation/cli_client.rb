require_relative 'game_manager_impl' # TODO: no impl

class CLIClient
	def initialize(input_stream=STDIN, output_stream=STDOUT)
		@in = input_stream
		@out = output_stream
		@controller = nil

		loop {
			command = @in.gets.strip
			if command.to_i.to_s == command
				place_token(command.to_i)
			elsif command == "start"
				start_game
			elsif command == "quit"
				end_game
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
		@out.puts("See you again! Hah hah hah hah hah hah!")
		exit
	end

	def place_token(column)
		if @controller.my_turn
			@controller.play(column)
		else
			@out.puts("It's not your turn!")
		end
	end
end

