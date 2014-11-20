require 'thread'
require_relative 'game_board'

class GameImpl
	def initialize(options, *views, &victory_condition)
		@options = options
		@views = views
		@victory_condition = victory_condition
		@commands = Queue.new
		@current_turn = options[:current_turn] || 1
		@board = options[:board] || GameBoard.new

		update_views({:board => board, :current_turn => @current_turn})
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
				update_views({:game_over => true, :winner => 0})
				return
			end

			board.add_token(command[:token], command[:column])

			winner = @victory_condition.call(board)
			if winner
				update_views({
					:board => board,
					:game_over => true,
					:winner => winner
				})
				return
			else
				update_views({
					:board => board,
					:current_turn => @current_turn
				})
			end
		rescue Exception => ex
			puts ex
		end
		end
	end
	
	def add_view(view)
		@views << view
		update_views({:board => @board, :current_turn => @current_turn})
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

	def update_views(update)
		@views.each{ |v| v.turn_update(update) }
	end

	def save
		@options.merge({
			:board => board.to_s,
			:current_turn => current_turn
		})
	end
end

