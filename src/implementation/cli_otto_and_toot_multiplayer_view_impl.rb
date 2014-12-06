require_relative 'cli_otto_and_toot_view'
require_relative 'cli_multiplayer_view'

# View for an otto and toot multiplayer command line game. Most functionality provided through
# the included modules.
class CLIOttoAndTootMultiplayerViewImpl
	include CLIOttoAndTootView
	include CLIMultiplayerView

	def initialize(output_stream)
		@out = output_stream
	end

	# Tell user what token they are playing and what they are trying to do. Then update
	# the board using super to call the modules to update the board.
	def turn_update(update)
		super

		unless update["game_over"]
			@out.puts(
				"Place the letter " \
				"'#{TOKEN_MAP[update["current_turn"]]}' " \
				"to try to spell the word " \
				"'#{VICTORY_MAP[update["current_turn"]]}'"
			)
		end
	end
end

