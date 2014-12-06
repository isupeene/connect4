require_relative 'game_board'

# Define how to update GUI for connect 4 game
module GUIConnect4View
	# Map player number to tokens.
	TOKEN_MAP = {
		nil => 0,
		1 => 'Red',
		2 => 'Black'
	}
	
	# Map player number to color to render.
	COLOR_MAP = {
		nil => Gdk::Color.parse("#FFFFFF"), #white
		1 => Gdk::Color.parse("#FF0000"), #red
		2 => Gdk::Color.parse("#000000") #black
	}
	
	# Update GUI with colors in places where tokens are.
	def print_board(board)
		GameBoard.load(board).each_with_index{ |x,i,j|
			button = @buttons[i][j]
			button.modify_bg(Gtk::STATE_NORMAL, COLOR_MAP[x])
		}
	end
end
