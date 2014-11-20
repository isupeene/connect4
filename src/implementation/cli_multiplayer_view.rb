module CLIMultiplayerView
	def turn_update(update)
		if update[:board]
			print_board(update[:board])
		end

		if update[:game_over]
			game_over(update[:winner])
		else
			puts("Player #{update[:current_turn]}'s turn.")
		end
	end

	def game_over(winner)
		if winner == 0
			@out.puts("Tie game!")
		else
			@out.puts("Player #{winner} wins!")
		end
	end
end
