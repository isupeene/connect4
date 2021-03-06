require 'set'

# Module containing victory conditions for different game modes.
module VictoryConditions

	ALL_DIRECTIONS = [
		[-1, -1], [-1,  0], [-1, 1], [0, -1],
		[0 ,  1], [ 1, -1], [ 1, 0], [1,  1]
	]

	# Check for winners by checking block with 4 tokens in a row in each direction
	# for all tokens. Set is used so a winner is only counted once.
	private
	def self.victory(board)
		winners = Set.new

		board.each_with_index { |x, i, j|
			next if x.nil?

			ALL_DIRECTIONS.each { |p, q|
				# Add winner if victory condition is met.
				if yield (0..3).map{ |m| 
					row = i + m*p
					col = j + m*q
					# Handle edges of board
					if row >= 0 && row < board.height && col >= 0 && col < board.width
						board[row, col]
					else
						nil
					end
				}
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
	# Victory condition for connect 4.
	def self.connect4(board)
		victory(board) { |a| Set.new(a).size == 1 }
	end

	# Victory condition for otto and toot.
	def self.otto_and_toot(board)
		victory(board) { |a|
			a[0] == a[3] &&
			a[1] == a[2] &&
			a[0] != a[1] &&
			!a.any?{ |x| x.nil? }
		}
	end
end
