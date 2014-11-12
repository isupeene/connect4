require 'test/unit'

module ControllerContract
	def play_precondition(i, j)
		assert(my_turn, "You can only move on your turn")
		assert(
			game.valid_move(i, j),
			"You can only place a token in a valid space."
		)
	end
	
	def play_postcondition(i, j, result)
		assert_equal(
			player_number, game.board[i, j],
			"After placing a token, the game board will be " \
			"(internally) marked with the player number."
		)
	end
end