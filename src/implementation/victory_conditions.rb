def connect4_victory_condition(board)
	board.each_with_index { |x, i, j|
		next if x.nil?

		[[-1, -1], [-1,  0], [-1, 1], [0, -1],
		 [0 ,  1], [ 1, -1], [ 1, 0], [1,  1]].each { |p, q|
			if [1, 2, 3].all?{ |m| board[i + m*p, j + m*q] == x }
				return x
			end
		}
	}
	return nil
end

