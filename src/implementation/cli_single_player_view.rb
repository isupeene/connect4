# Defines how to update board and report actions to user for a single player
# game in the command line.
module CLISinglePlayerView
	# Callback that model calls. Specific classes override this method
	# to print specific messages and must then call super for proper
	# functionality.
	def turn_update(update)
		if update["board"]
			print_board(update["board"])
		end

		if update["game_over"]
			game_over(update["winner"])
		elsif update["current_turn"] == @player_number
			puts("Your turn.")
		else
			puts("AI's turn")
		end
	end

	# Displays end game messages.
	def game_over(winner)
		case winner
		when 0
			@out.puts("Tie game!")
		when @player_number
			@out.puts("You win!")
		else
			@out.puts("Try again!")
		end
	end
end

