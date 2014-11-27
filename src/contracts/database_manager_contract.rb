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
	
	def update_leaderboard_precondition(player, victory)
		assert(
			(0..2) === victory,
			"Player must have won, lost, or tied."
		)
	end
	
	def update_leaderboard_invariant(player, victory, result)
		old_stats = leaderboard[player]
		if old_stats.nil?
			old_stats = Stats.new
		end
		yield
		new_stats = leaderboard[player]
		msg = "Leaderboards failed to update."
		case victory
		when 0
			assert_equals(old_stats.losses + 1, new_stats.losses, msg)
		when 1
			assert_equals(old_stats.wins + 1, new_stats.wins, msg)
		when 2
			assert_equals(old_stats.ties + 1, new_stats.ties, msg)
		end
	end
end
