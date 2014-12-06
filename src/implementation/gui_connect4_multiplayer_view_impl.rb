require_relative 'gui_connect4_view'
require_relative 'gui_multiplayer_view'

# View for an connect 4 multiplayer GUI game. Most functionality provided through
# the included modules.
class GUIConnect4MultiplayerViewImpl
	include GUIConnect4View
	include GUIMultiplayerView

	def initialize(buttons, displays)
		@buttons = buttons
		@displays = displays
	end
	
	# Tell user what token they are playing and what they are trying to do. Then update
	# the board using super to call the modules to update the board.
	def turn_update(update)
		super

		unless update["game_over"]
			@displays[1].set_label("You are #{TOKEN_MAP[update["current_turn"]]}.")
			@displays[2].set_label("Try to get 4 in a row.")
		end
	end
end
