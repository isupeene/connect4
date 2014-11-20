require_relative 'gui_single_player_view'
require_relative 'gui_otto_and_toot_view'

# View for an otto and toot single player GUI game. Most functionality provided through
# the included modules.
class GUIOttoAndTootSinglePlayerViewImpl
	include GUISinglePlayerView
	include GUIOttoAndTootView

	def initialize(buttons, displays, player_number)
		@buttons = buttons
		@displays = displays
		@player_number = player_number
	end

	# Tell user what token they are playing and what they are trying to do. Then update
	# the board using super to call the modules to update the board.
	def turn_update(update)
		super

		if !update[:game_over] && update[:current_turn] == @player_number
			@displays[1].set_label("You are placing #{TOKEN_MAP[@player_number]}.")
			@displays[2].set_label("Try to spell the word '#{VICTORY_MAP[@player_number]}'.")
		end
	end
end