require 'test/unit'
require_relative 'controller_contract'

module GameContract
	def invariant
		assert(
			board.each_with_index.all? { |t, i, j|
				(i < board.height - board.number_of_tokens(j) && t.nil?) ||
				(i >= board.height - board.number_of_tokens(j) && 1..2 === t)
			},
			"Each position on the board is either empty, " \
			"or contains a valid player token.\n" \
			"Columns are filled from the bottom up."
		)
		assert_equals(
			7, board.width,
			"The game board has a width of 7."
		)
		assert_equals(
			6, board.height,
			"The game board has a height of 6."
		)
	end
	
	def play_precondition(column, player_number)
		assert(1..2 === player_number, "There exists only player 1 and player 2.")
		assert(valid_move(column), "Invalid move is invalid.")
		assert(current_turn == player_number, "You may only play on your turn.")
	end
	
	def play_postcondition(column, player_number, result)
		assert_equals(
			player_number, board[-board.number_of_tokens(column), column],
			"The board will be marked with the player number."
		)
		
		# TODO: Somehow assert that a turn update or a game over message has been sent to all views.
	end
	
	def play_invariant(column, player_number, result)
		previous_number_of_tokens = board.number_of_tokens(column)
		yield
		assert_equals(previous_number_of_tokens + 1, board.number_of_tokens(column))
	end
end
