require_relative 'game_impl' # TODO: no impl
require_relative 'ai_view_impl'
require_relative 'connect4_ai_impl'
require_relative 'controller_impl'
require_relative 'victory_conditions'

module GameManagerImpl
	@@game = nil

	def self.start_game(game_options={}, *views)
		views << AIViewImpl.new if game_options[:single_player]

		@@game = GameImpl.new(
			game_options,
			*views,
			self,
			&get_victory_condition(game_options)
		)

		if game_options[:single_player]
			get_ai_class(game_options).new(views[-1], ControllerImpl.new(@@game, 2))
			return ControllerImpl.new(@@game, 1)
		else
			return [1, 2].map{ |i| ControllerImpl.new(@@game, i) }
		end
	end

	def self.get_ai_class(game_options)
		# TODO: Connect4 vs OTTO and TOOT
		Connect4AIImpl
	end

	def self.get_victory_condition(game_options)
		# TODO: Connect4 vs OTTO and TOOT
		Proc.new{ |b| VictoryConditions.connect4(b) }
	end

	def self.end_game
		@@game.quit
		@@game = nil
	end

	def self.save_game
		begin
			File.open("connect4.sav", "w") { |savefile|
				savefile.write(@@game.save)
			}
			return true
		rescue Exception => ex
			puts ex
			return false
		end
	end

	def self.load_game
		begin
			options = nil
			File.open("connect4.sav", "r") { |savefile|
				# Vulnerable to trojans;
				# Don't play connect4 as root!
				options = eval(savefile.readlines.join)
				options[:board] = GameBoard.load(options[:board])
			}
			start_game(options)
		rescue Exception => ex
			puts ex
			return nil
		end
	end

	def self.game_in_progress
		!@@game.nil?
	end

	def self.save_file_present
		File.file?("connect4.sav")
	end

	def self.turn_update(update)
		@@game = nil if update[:game_over]
	end
end
