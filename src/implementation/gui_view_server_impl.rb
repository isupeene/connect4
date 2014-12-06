require_relative "gui_connect4_multiplayer_view_impl"
require_relative "gui_otto_and_toot_multiplayer_view_impl"

class GUIViewServerImpl
	def initialize(buttons, view_displays)
		@buttons = buttons
		@view_displays = view_displays
		@player_number = nil
		@active_view = nil

		@connect4_view = GUIConnect4MultiplayerViewImpl.new(@buttons, @view_displays)
		@otto_and_toot_view = GUIOttoAndTootMultiplayerViewImpl.new(@buttons, @view_displays)
	end

	def set_otto_and_toot
		@active_view = @otto_and_toot_view
	end

	def set_connect4
		@active_view = @connect4_view
	end

	def deactivate
		@active_view = nil
	end

	def set_player_number(number)
		@player_number = number
	end

	def turn_update(update)
		if update["board"]
			print_board(update["board"])
		end

		if update["game_over"]
			game_over(update["winner"])
		end
		return true
	end

	def print_board(board)
		@active_view.print_board(board) if @active_view
	end
	
	def game_over(winner)
		@active_view.game_over(winner) if @active_view
	end
end