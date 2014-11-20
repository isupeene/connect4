module CLIOttoAndTootView
	TOKEN_MAP = {
		nil => 0,
		1 => 'O',
		2 => 'T'
	}

	VICTORY_MAP = {
		1 => "OTTO",
		2 => "TOOT"
	}

	def print_board(board)
		@out.puts(board.rows.map { |r|
			r.map{ |x| TOKEN_MAP[x] }.join(" ")
		}.join("\n"))
	end
end

