require 'test/unit'
require_relative 'controller_contract'

module GameManagerContract
	def start_game_postcondition(game_type, result)
		assert(
			result.is_a?(ControllerContract),
			"Starting a new game returns the human player's controller."
		)
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
		assert(
			result.is_a?(ControllerContract),
			"Starting a new game returns the human player's controller."
		)
		assert(game_in_progress)
	end
	
	def quit_game_precondition
		assert(game_in_progress)
	end
	
	def quit_game_postcondition(result)
		assert(!game_in_progress)
	end
end
