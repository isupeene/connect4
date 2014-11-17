class GameBoard
	def initialize
		# Reverse i and j so we can access the columns more easily.
		@board = Array.new(width){Array.new(height)}
	end

	def width
		7
	end

	def height
		6
	end

	def []=(i, j, x)
		board[j][i] = x
	end

	def [](i, j)
		board[j][i]
	end

	def number_of_tokens(column)
		@board[column].count{ |x| x }
	end

	def add_token(token, column)
		self[-1 - number_of_tokens(column), column] = token
	end
end

