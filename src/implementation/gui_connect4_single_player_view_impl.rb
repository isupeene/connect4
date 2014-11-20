require_relative 'gui_connect4_view'
require_relative 'gui_single_player_view'

class GUIConnect4SinglePlayerViewImpl
	include GUIConnect4View
	include GUISinglePlayerView

	def initialize(buttons, displays, player_number)
		@buttons = buttons
		@displays = displays
		@player_number = player_number
	end
	
	def turn_update(update)
		super

		if !update[:game_over] && update[:current_turn] == @player_number
			@displays[1].set_label("You are #{TOKEN_MAP[@player_number]}.")
			@displays[2].set_label("Try to get 4 in a row.")
		end
	end
end