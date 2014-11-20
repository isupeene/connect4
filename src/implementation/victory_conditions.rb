require 'set'

module VictoryConditions

	ALL_DIRECTIONS = [
		[-1, -1], [-1,  0], [-1, 1], [0, -1],
		[0 ,  1], [ 1, -1], [ 1, 0], [1,  1]
	]

	private
	def self.victory(board)
		winners = Set.new

		board.each_with_index { |x, i, j|
			next if x.nil?

			ALL_DIRECTIONS.each { |p, q|
				if yield (0..3).map{ |m| board[i + m*p, j + m*q] }
					winners.add(x)
				end
			}
		}
		if winners.size == 1
			return winners.first
		elsif winners.size > 1
			return 0
		end

		if (0...board.width).all?{ |i| board.number_of_tokens(i) == board.height }
			return 0
		else
			return nil
		end
	end

	public
	def self.connect4(board)
		victory(board) { |a| Set.new(a).size == 1 }
	end
end
