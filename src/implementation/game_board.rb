# Representation of a game board.
class GameBoard
	include Enumerable

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

	# Set token in board
	def []=(i, j, x)
		@board[j][i] = x
	end

	# Get token from board.
	def [](i, j)
		(@board[j] || [])[i]
	end

	# Return number of non-nil tokens in the given column of the board.
	def number_of_tokens(column)
		@board[column].count{ |x| x }
	end

	# Add token to lowest empty spot in given column.
	def add_token(token, column)
		self[-1 - number_of_tokens(column), column] = token
	end

	def columns
		@board
	end

	def rows
		@board.transpose
	end

	def each
		return to_enum(:each) unless block_given?
		each_with_index{ |x, i, j| yield x }
	end

	def each_with_index
		return to_enum(:each_with_index) unless block_given?
		@board.each_with_index { |c, j|
			c.each_with_index{ |x, i| yield x, i, j }
		}
	end

	def to_s
		@board.to_s
	end

	attr_accessor :board

	# Load board from string.
	public
	def self.load(str)
		result = new
		result.board = eval(str)
		return result
	end
end

