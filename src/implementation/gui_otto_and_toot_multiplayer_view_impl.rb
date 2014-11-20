require_relative 'gui_otto_and_toot_view'
require_relative 'gui_multiplayer_view'

class GUIOttoAndTootMultiplayerViewImpl
	include GUIOttoAndTootView
	include GUIMultiplayerView

	def initialize(buttons, displays)
		@buttons = buttons
		@displays = displays
	end

	def turn_update(update)
		super

		unless update[:game_over]
			@displays[1].set_label("You are placing #{TOKEN_MAP[update[:current_turn]]}.")
			@displays[2].set_label("Try to spell the word '#{VICTORY_MAP[update[:current_turn]]}'.")
		end
	end
end