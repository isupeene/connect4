require 'test/unit'
require_relative 'game_contract'

module DatabaseManagerContract
	def save_game_precondition(player1, player2, game)
		assert(game.is_a?(GameContract), "A game is a game.")
	end
	
	def save_game_postcondition(player1, player2, game, result)
		assert_equals(game, load_game(result))
	end
	
	def load_game_precondition(id)
		assert(id.is_a?(Integer), "Games are given integer IDs in the MySQL database.")
		assert(game_list.map{ |entry| entry.id }.include?(id), "The provided id should exist.")
	end
	
	def load_game_postcondition(id, result)
		if result
			assert(result.is_a?(GameContract), "A game is a game.")
		else
			assert(
				!game_list.map{ |entry| entry.id }.include?(id),
				"If no game is returned, it means it was deleted before we could access it."
			)
		end
	end
	
	def game_list_postcondition(result)
		assert(
			result.is_a?(Enumerable) && result.all?{ |game| game.is_a?(GameContract) },
			"Every game is a game!"
		)
	end
end