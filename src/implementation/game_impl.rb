require 'thread'
require_relative 'game_board'
require_relative 'remote_view_impl' # TODO: no impl

# Model class that contains all information relative to a game.
class GameImpl
	# Make new game based on given options, views that need to be updated
	# and victory condition.
	def initialize(options, *views, &victory_condition)
		@options = options
		@views = views
		@victory_condition = victory_condition
		@commands = Queue.new
		@current_turn = options['current_turn'] || 1
		@board = options['board'] || GameBoard.new
		@player_names = options['player_names'] || ["",""]
		@game_type = options['otto_and_toot'] ? 2 : 1

		update_views({"board" => board.to_s, "current_turn" => @current_turn})
		game_thread = Thread.new{ main_loop }
		game_thread.priority = 3
	end

	attr_reader :current_turn
	attr_reader :options
	attr_reader :board
	attr_reader :player_names
	attr_reader :game_type

	# Loop that handles commands from controllers via a queue and then updates the board and
	# the views after each command is processed.
	def main_loop
		loop do
		begin
			command = @commands.pop
			if command["cancel"]
				update_views({"game_over" => true, "winner" => 0})
				return
			end

			board.add_token(command["token"], command["column"])

			winner = get_winner
			if winner
				update_views({
					"board" => board.to_s,
					"game_over" => true,
					"winner" => winner
				})
				return
			else
				update_views({
					"board" => board.to_s,
					"current_turn" => @current_turn
				})
			end
		rescue Exception => ex
			puts ex
		end
		end
	end
	
	# Add another view to be updated to the game
	def add_view(view)
		@views << view
		view.turn_update({"board" => @board.to_s, "current_turn" => @current_turn})
	end
	
	# Place a token equal to the player number in the column of the board.
	def play(column, player_number)
		# Increment player number first, to avoid a race
		# condition when the AI player gets the update.
		@current_turn ^= 3
		@commands.push({"token" => player_number, "column" => column})
	end

	# Ends game and notifies views of this.
	def quit
		@commands.push({"cancel" => true})
	end
	
	def set_player_name(player_number, name)
		@player_names[player_number -1] = name
	end
	
	def get_winner
		@victory_condition.call(@board)
	end

	# Determines if a move to play a token is valid.
	def valid_move(column)
		column >= 0 &&
		column < board.width &&
		board.number_of_tokens(column) < board.height
	end

	# Update all listening views.
	def update_views(update)
		@views.each{ |v| v.turn_update(update) }
	end

	# Save game state.
	def save
		@options.merge({
			"board" => board.to_s,
			"current_turn" => current_turn
		})
	end
end

