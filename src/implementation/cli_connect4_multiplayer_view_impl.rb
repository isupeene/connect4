require_relative 'cli_connect4_view'
require_relative 'cli_multiplayer_view'

# View for a connect4 multiplayer command line game. Most functionality provided through
# the included modules.
class CLIConnect4MultiplayerViewImpl
	include CLIConnect4View
	include CLIMultiplayerView

	def initialize(output_stream)
		@out = output_stream
	end
end

