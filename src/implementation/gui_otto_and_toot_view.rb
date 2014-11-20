# Define how to update the GUI for an otto and toot game.
module GUIOttoAndTootView
	# Map player numbers to tokens.
	TOKEN_MAP = {
		nil => '',
		1 => 'O',
		2 => 'T'
	}

	# Map player numbers to victory conditions.
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