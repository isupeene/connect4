require 'test/unit'
require_relative 'controller_contract'

module GameContract
	def invariant
		assert(
			board.all{ |t| t.nil? || 1..2 === t },
			"Each position on the board is either empty, " \
			"or contains a valid player token."
		)
	end

	def controllers_postcondition(controllers)
		assert(controllers.all?{ |c| c.is_a?(ControllerContract) })
		controller_1, controller_2 = *controllers
		
		assert_equals(
			1, controller_1.player_number,
			"The first controller will belong to player 1."
		)
		
		assert_equals(
			2, controller_2.player_number,
			"The second controller will belong to player 2."
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
end