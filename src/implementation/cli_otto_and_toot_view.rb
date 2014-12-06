require_relative "game_board"

module CLIOttoAndTootView
	# Map players to tokens.
	TOKEN_MAP = {
		nil => 0,
		1 => 'O',
		2 => 'T'
	}

	# Map players to victory conditions.
	VICTORY_MAP = {
		1 => "OTTO",
		2 => "TOOT"
	}

	# Define how to print an otto and toot board to the command line.
	def print_board(board)
		@out.puts(GameBoard.load(board).rows.map { |r|
			r.map{ |x| TOKEN_MAP[x] }.join(" ")
		}.join("\n"))
	end
end

