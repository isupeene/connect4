require_relative 'gui_connect4_view'
require_relative 'gui_multiplayer_view'

class GUIConnect4MultiplayerViewImpl
	include GUIConnect4View
	include GUIMultiplayerView

	def initialize(buttons, displays)
		@buttons = buttons
		@displays = displays
	end
	
	def turn_update(update)
		super

		unless update[:game_over]
			@displays[1].set_label("You are #{TOKEN_MAP[update[:current_turn]]}.")
			@displays[2].set_label("Try to get 4 in a row.")
		end
	end
end