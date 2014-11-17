def connect4_victory_condition(board)
	board.each_with_index { |x, i, j|
		next if x.nil?

		[[-1, -1], [-1,  0], [-1, 1], [0, -1],
		 [0 ,  1], [ 1, -1], [ 1, 0], [1,  1]].each { |p, q|
			if [1, 2, 3].all?{ |m|
				(0...board.height) === i + m*p &&
				(0...board.width) === j + m*q &&
				board[i + m*p, j + m*q] == x
			}
				return x
			end
		}
	}
	if (0...board.width).all?{|i| board.number_of_tokens(i) == board.height }
		return 0
	else
		return nil
	end
end

