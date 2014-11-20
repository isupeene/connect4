module GUIMultiplayerView
	def turn_update(update)
		if update[:board]
			print_board(update[:board])
		end

		if update[:game_over]
			game_over(update[:winner])
		else
			@displays[0].set_label("Player #{update[:current_turn]}'s turn. ")
		end
	end

	def game_over(winner)
		if winner == 0
			@displays[0].set_label("Tie game!")
		else
			@displays[0].set_label("Player #{winner} wins!")
		end
		@displays[1].set_label("")
		@displays[2].set_label("")
	end
end