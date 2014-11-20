require_relative 'cli_otto_and_toot_view'
require_relative 'cli_multiplayer_view'

class CLIOttoAndTootMultiplayerViewImpl
	include CLIOttoAndTootView
	include CLIMultiplayerView

	def initialize(output_stream)
		@out = output_stream
	end

	def turn_update(update)
		super

		unless update[:game_over]
			@out.puts(
				"Place the letter " \
				"'#{TOKEN_MAP[update[:current_turn]]}' " \
				"to try to spell the word " \
				"'#{VICTORY_MAP[update[:current_turn]]}'"
			)
		end
	end
end

