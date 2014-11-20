module GUIOttoAndTootView
	TOKEN_MAP = {
		nil => '',
		1 => 'O',
		2 => 'T'
	}

	VICTORY_MAP = {
		1 => "OTTO",
		2 => "TOOT"
	}

	# Update GUI with values for tokens. 
	def print_board(board)
		board.each_with_index{ |x,i,j|
			button = @buttons[i][j]
			button.set_label(TOKEN_MAP[x])
		}
	end
end