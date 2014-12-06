require_relative 'gui_connect4_view'
require_relative 'gui_single_player_view'

# View for an connect 4 single player GUI game. Most functionality provided through
# the included modules.
class GUIConnect4SinglePlayerViewImpl
	include GUIConnect4View
	include GUISinglePlayerView

	def initialize(buttons, displays, player_number)
		@buttons = buttons
		@displays = displays
		@player_number = player_number
	end
	
	# Tell user what token they are playing and what they are trying to do. Then update
	# the board using super to call the modules to update the board.
	def turn_update(update)
		super

		if !update["game_over"] && update["current_turn"] == @player_number
			@displays[1].set_label("You are #{TOKEN_MAP[@player_number]}.")
			@displays[2].set_label("Try to get 4 in a row.")
		end
	end
end
