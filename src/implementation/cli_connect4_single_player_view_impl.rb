require_relative 'cli_connect4_view'
require_relative 'cli_single_player_view'

class CLIConnect4SinglePlayerViewImpl
	include CLIConnect4View
	include CLISinglePlayerView

	def initialize(output_stream, player_number)
		@out = output_stream
		@player_number = player_number
	end
end

