# Defines how to update board and report actions to user for a multiplayer
# game in the command line.
module CLIMultiplayerView
	# Callback that model calls. Specific classes override this method
	# to print specific messages and must then call super for proper
	# functionality.
	def turn_update(update)
		if update["board"]
			print_board(update["board"])
		end

		if update["game_over"]
			game_over(update["winner"])
		else
			puts("Player #{update["current_turn"]}'s turn.")
		end
	end

	# Displays end game messages.
	def game_over(winner)
		if winner == 0
			@out.puts("Tie game!")
		else
			@out.puts("Player #{winner} wins!")
		end
	end
end

