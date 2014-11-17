require 'thread'
require_relative 'game_board'

class GameImpl
	def initialize(options, *views, &victory_condition)
		@options = options
		@views = views
		@victory_condition = victory_condition
		@commands = Queue.new
		@current_turn = 1
		@board = GameBoard.new

		@views.each{ |v| v.turn_update(board) }
		game_thread = Thread.new{ main_loop }
		game_thread.priority = 3
	end

	attr_reader :current_turn
	attr_reader :options
	attr_reader :board

	def main_loop
		loop do
		begin
			command = @commands.pop
			if command[:cancel]
				@views.each{ |v| v.game_over(0) }
				return
			end

			board.add_token(command[:token], command[:column])
			@views.each{ |v| v.turn_update(board) }

			victory = @victory_condition.call(board)
			if victory
				@views.each{ |v| v.game_over(victory) }
				return
			end
		rescue Exception => ex
			puts ex
		end
		end
	end

	def play(column, player_number)
		# Increment player number first, to avoid a race
		# condition when the AI player gets the update.
		@current_turn ^= 3
		@commands.push({:token => player_number, :column => column})
	end

	def quit
		@commands.push({:cancel => true})
	end

	def valid_move(column)
		column >= 0 &&
		column < board.width &&
		board.number_of_tokens(column) < board.height
	end
end

