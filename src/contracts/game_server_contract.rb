require 'test/unit'
require_relative 'game_manager_contract'

module GameServerContract
	include GameManagerContract
	
	def join_invariant(player)
		old_players = players.dup
		yield
		assert(
			old_players.all?{ |p| players.include?(p) },
			"Everyone else is still here."
		)
		if (old_players.length < 2)
			assert(
				players.include?(player),
				"A player can join the game if there's room."
			)
		else
			assert(
				!players.include?(player),
				"A player cannot join the game if there's not room."
			)
		end
	end
	
	def start_game_precondition(game_options)
		super
		assert_equals(
			2, players.length,
			"There should be two players before you start a game."
		)
	end
	
	def load_game_precondition(id)
		database.load_game_precondition(id)
	end
	
	def load_game_postcondition(id, result)
		super(result)
	end
end