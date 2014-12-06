gem "test-unit"
require 'test/unit'
require_relative '../game'
require_relative '../ai_view'
require_relative 'connect4_ai'
require_relative '../controller'
require_relative 'victory_conditions'

# Manages game creation, deletion, saving, and loading.
class GameManagerImpl
	@game = nil

	# Start a new game based on the given game options.
	# views are the views that the game should provide
	# updates to.
	def start_game(game_options={}, *views)
		views << AIView.new if game_options["single_player"]

		@game = Game.new(
			game_options,
			*views,
			self,
			&get_victory_condition(game_options)
		)

		if game_options["single_player"]
			get_ai_class(game_options).new(views[-1], Controller.new(@game, 2))
			return Controller.new(@game, 1)
		else
			return [1, 2].map{ |i| Controller.new(@game, i) }
		end
	end

	# Get AI class to make. Currently only 1 type of AI.
	def get_ai_class(game_options)
		Connect4AI # lol
	end

	# Choose victory condition based on game options
	def get_victory_condition(game_options)
		if game_options["otto_and_toot"]
			Proc.new{ |b| VictoryConditions.otto_and_toot(b) }
		else
			Proc.new{ |b| VictoryConditions.connect4(b) }
		end
	end
	
	# Return current game's options.
	def get_options
		@game.options
	end
	
	# Add a new view to the current game
	def add_view(view)
		@game.add_view(view)
	end

	# End the current game
	def end_game
		# So that we don't update the leaderboards
		# when a game is quit prematurely.
		g = @game
		@game = nil
		g.quit
		return true
	end

	# Save current game state to a file for future playing.
	def save_game
		begin
			File.open("connect4.sav", "w") { |savefile|
				savefile.write(@game.save)
			}
			return true
		rescue Exception => ex
			puts ex
			return false
		end
	end

	# Load game from file if one exists.
	def load_game
		begin
			options = nil
			File.open("connect4.sav", "r") { |savefile|
				# Vulnerable to trojans;
				# Don't play connect4 as root!
				options = eval(savefile.readlines.join)
				options["board"] = GameBoard.load(options["board"])
			}
			start_game(options)
		rescue Exception => ex
			puts ex
			return nil
		end
	end

	# Tells if a game is currently going.
	def game_in_progress
		!@game.nil?
	end

	# Tells if a save file is available for loading
	def save_file_present
		File.file?("connect4.sav")
	end

	# Callback that game model calls. Tells manager when game is over.
	def turn_update(update)
		@game = nil if update["game_over"]
	end
end
