require_relative 'game_impl' # TODO: no impl
require_relative 'ai_view_impl'
require_relative 'connect4_ai_impl'
require_relative 'cli_connect4_view_impl'
require_relative 'controller_impl'
require_relative 'victory_conditions'

module GameManagerImpl
	def self.start_game(game_options)
		# TODO: For now, we assume CLI, single-player and connect 4.
		# These can be made part of the game options.

		ai_view = AIViewImpl.new
		
		@@game = GameImpl.new(
			game_options,
			ai_view,
			CLIConnect4ViewImpl.new(STDOUT, 1)
		) { |b| connect4_victory_condition(b) }

		
		Connect4AIImpl.new(ai_view, ControllerImpl.new(@@game, 2))
		return ControllerImpl.new(@@game, 1)
	end

	def self.end_game
		@@game.quit
		@@game = nil
	end

	def self.game_in_progress
		!@@game.nil?
	end
end
