gem "test-unit"
require 'test/unit'
require_relative 'controller_contract'

module GameManagerContract
	def start_game_postcondition(game_options={}, *views, result)
		if game_options[:single_player]
			assert(
				result.is_a?(ControllerContract),
				"Starting a new game returns the human player's controller."
			)
		else
			assert_equal(2, result.length, "Two controllers are returned.")
			assert(result.all?{ |c| c.is_a?(ControllerContract) })
			
			controller_1, controller_2 = *result
			assert_equal(1, controller_1.player_number)
			assert_equal(2, controller_2.player_number)
		end
		
		assert(game_in_progress)
	end
	
	def save_game_precondition
		assert(game_in_progress)
	end
	
	def save_game_postcondition(result)
		assert(save_file_present)
	end
	
	def load_game_precondition
		assert(save_file_present)
	end
	
	def load_game_postcondition(result)
		start_game_postcondition(get_options, result)
	end
	
	def quit_game_precondition
		assert(game_in_progress)
	end
	
	def quit_game_postcondition(result)
		assert(!game_in_progress)
	end
end
