class CLIConnect4ViewImpl
	def initialize(output_stream, player_number)
		@out = output_stream
		@player_number = player_number
	end

	def turn_update(board)
		@out.puts(board.rows.map { |r| 
			r.map{ |x| x.nil? ? 0 : x }.join(" ")
		}.join("\n"))
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

