class ControllerImpl
	def initialize(game, player_number)
		@game = game
		@player_number = player_number
	end

	attr_reader :game
	attr_reader :player_number

	def my_turn
		game.current_turn == player_number
	end

	def play(column)
		game.play(column, player_number)
	end
end

