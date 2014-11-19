require 'test/unit'

module ControllerContract
	def play_precondition(column)
		assert(my_turn, "You can only move on your turn")
		assert(
			game.valid_move(column),
			"You can only place a token in a valid column with room remaining."
		)
	end
	
	def play_postcondition(column, result)
		assert_equal(
			player_number, game.board[-game.board.number_of_tokens(column), column],
			"After placing a token, the game board will be " \
			"(internally) marked with the player number."
		)
	end
	
	def play_invariant(column)
		# TODO: We can also assert that no other columns are affected.
		previous_number_of_tokens = game.board.number_of_tokens(column)
		yield
		assert_equals(previous_number_of_tokens + 1, game.board.number_of_tokens(column))
	end
end
