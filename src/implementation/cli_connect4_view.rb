module CLIConnect4View
	def print_board(board)
		@out.puts(board.rows.map { |r| 
			r.map{ |x| x.nil? ? 0 : x }.join(" ")
		}.join("\n"))
	end
end
