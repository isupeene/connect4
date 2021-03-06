module GUISinglePlayerView
	# Callback that game model calls when game changes. Updates GUI
	# board and message.
	def turn_update(update)
		if update["board"]
			print_board(update["board"])
		end

		if update["game_over"]
			game_over(update["winner"])
		elsif update["current_turn"] == @player_number
			@displays[0].set_label("Your turn.")
		else
			@displays[0].set_label("AI's turn")
		end
	end

	# Called when game ends. Displays winner info to GUI.
	def game_over(winner)
		case winner
		when 0
			@displays[0].set_label("Tie game!")
		when @player_number
			@displays[0].set_label("You win!")
		else
			@displays[0].set_label("Try again!")
		end
		@displays[1].set_label("")
		@displays[2].set_label("")
	end
end
