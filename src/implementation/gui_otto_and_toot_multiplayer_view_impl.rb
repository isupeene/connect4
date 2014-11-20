require_relative 'gui_otto_and_toot_view'
require_relative 'gui_multiplayer_view'

# View for an otto and toot multiplayer GUI game. Most functionality provided through
# the included modules.
class GUIOttoAndTootMultiplayerViewImpl
	include GUIOttoAndTootView
	include GUIMultiplayerView

	def initialize(buttons, displays)
		@buttons = buttons
		@displays = displays
	end

	# Tell user what token they are playing and what they are trying to do. Then update
	# the board using super to call the modules to update the board.
	def turn_update(update)
		super

		unless update[:game_over]
			@displays[1].set_label("You are placing #{TOKEN_MAP[update[:current_turn]]}.")
			@displays[2].set_label("Try to spell the word '#{VICTORY_MAP[update[:current_turn]]}'.")
		end
	end
end