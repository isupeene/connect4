require 'test/unit'
require_relative 'game_manager_contract'

module GameServerContract
	include GameManagerContract
	
	def join_precondition(player)
		assert(players.length < 2, "There can be only 2.")
	end
	
	def join_invariant(player)
		old_players = players.dup
		yield
		assert(
			old_players.all?{ |p| players.include?(p) },
			"Everyone else is still here."
		)
	end
	
	def join_postcondition(player, result)
		assert(players.include?(player), "The player has joined the game.")
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