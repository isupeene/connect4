require 'test/unit'
require_relative 'game_contract'
require_relative '../stats'

module DatabaseManagerContract
	def save_game_precondition(player1, player2, game)
		assert(game.is_a?(GameContract), "A game is a game.")
	end
	
	def save_game_postcondition(player1, player2, game, result)
		assert_equals(game, load_game(result))
	end
	
	def load_game_precondition(id)
		assert(id.is_a?(Integer), "Games are given integer IDs in the MySQL database.")
		assert(saved_games.map{ |entry| entry.id }.include?(id), "The provided id should exist.")
	end
	
	def load_game_postcondition(id, result)
		if result
			assert(result.is_a?(GameContract), "A game is a game.")
		end
		assert(
			!saved_games.map{ |entry| entry.id }.include?(id),
			"If we successfully loaded the game, the old save file will be deleted.\n" \
			"If we failed to load the game, it means someone else got to it first, and it was deleted."
		)
	end
	
	def saved_games_postcondition(result)
		assert(
			result.is_a?(Enumerable) && result.all?{ |game| game.is_a?(GameContract) },
			"Every game is a game!"
		)
	end
	
	def save_results_precondition(player1, player2, game)
		assert(game.is_a?(GameContract), "Can only save game results.")
		assert(
			(0..2) === game.victory,
			"Player must have won or a tie game."
		)
	end
	
	def save_results_postcondtion(player1, player2, game, result)
		game_result = get_result(result)
		assert(game_result.victory == game.victory && 
			game_result.player1 == player1 && 
			game_result.player2 == player2 && 
			game_result.game_type == game.game_type,
			"Result should be stored correctly."
		)
	end
	
	def get_result_precondition(id)
		assert(id.is_a?(Integer), "Game results are given integer IDs in the MySQL database.")
		assert(get_results.map{ |result| result.id }.include?(id), "The provided id should exist.")
	end
	
	def get_result_postcondition(id, result)
		assert(result.is_a?(Result), "A result is a result.")
	end
	
	def get_results_postcondition(result)
		assert(
			result.is_a?(Enumerable) && result.all?{ |game_result| game_result.is_a?(GameResult)}, 
			"Every result is a result."
		)
	end
	
	def leaderboards_postcondition(result)
		assert(
			result.is_a?(Enumerable) && result.all?{ |player_stats| player_stats.is_a?(Stats) },
			"Every leaderboard entry contains a player's stats."
		)
	end
end
