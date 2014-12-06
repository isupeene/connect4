require_relative "cli_connect4_multiplayer_view_impl"
require_relative "cli_otto_and_toot_multiplayer_view_impl"

class CLIViewServerImpl
	def initialize(output_stream)
		@out = output_stream
		@player_number = nil
		@active_view = nil

		@connect4_view = CLIConnect4MultiplayerViewImpl.new(@out)
		@otto_and_toot_view = CLIConnect4MultiplayerViewImpl.new(@out)
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
		# HACK: Can't send GameBoard object over XMLRPC
		if update["board"]
			update["board"] = GameBoard.load(update["board"])
		end

		if update["board"]
			print_board(update["board"])
		end

		if update["game_over"]
			game_over(update["winner"])
		else
			display_turn(update["current_turn"])
		end
		return true
	end

	def print_board(board)
		@active_view.print_board(board) if @active_view
	end

	def game_over(winner)
		if winner == 0
			@out.puts("Tie game!")
		elsif winner == @player_number
			@out.puts("You win!")
		else
			@out.puts("You lose!")
		end
	end

	def display_turn(player)
		if @player_number == player
			@out.puts("Your turn.")
		else
			@out.puts("Waiting for the opponent...")
		end
	end
end

