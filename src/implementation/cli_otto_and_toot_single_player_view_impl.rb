require_relative 'cli_single_player_view'
require_relative 'cli_otto_and_toot_view'

# View for an otto and toot single player command line game. Most functionality provided through
# the included modules.
class CLIOttoAndTootSinglePlayerViewImpl
	include CLISinglePlayerView
	include CLIOttoAndTootView

	def initialize(output_stream, player_number)
		@out = output_stream
		@player_number = player_number
	end

	# Tell user what token they are playing and what they are trying to do. Then update
	# the board using super to call the modules to update the board.
	def turn_update(update)
		super

		if !update["game_over"] && update["current_turn"] == @player_number
			@out.puts(
				"Place the letter " \
				"'#{TOKEN_MAP[@player_number]}' " \
				"to try to spell the word " \
				"'#{VICTORY_MAP[@player_number]}'"
			)
		end
	end
end

