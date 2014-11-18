class CLIConnect4ViewImpl
	def initialize(output_stream, player_number)
		@out = output_stream
		@player_number = player_number
	end

	def turn_update(update)
		if update[:board]
			@out.puts(update[:board].rows.map { |r| 
				r.map{ |x| x.nil? ? 0 : x }.join(" ")
			}.join("\n"))
		end

		if update[:game_over]
			game_over(update[:winner])
		elsif update[:current_turn] == @player_number
			puts("Your turn.")
		else
			puts("AI's turn")
		end
	end

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

