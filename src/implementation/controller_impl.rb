# Controller class that clients use to change the game state.
class ControllerImpl
	def initialize(game, player_number)
		@game = game
		@player_number = player_number
	end

	attr_reader :game
	# Player number associated with this controller.
	attr_reader :player_number

	# Determine if it is this controller's turn.
	def my_turn
		game.current_turn == player_number
	end

	# Play a token in the game in the given column.
	def play(column)
		game.play(column, player_number)
		return true
	end

	def valid_move(column)
		game.valid_move(column)
	end
end


