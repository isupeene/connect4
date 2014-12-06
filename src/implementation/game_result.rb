class GameResult
	
	attr_accessor :player1
	attr_accessor :player2
	attr_accessor :winner
	attr_accessor :game_type
	
	def initialize(player1, player2, winner, game_type)
		@player1 = player1
		@player2 = player2
		@winner = winner
		@game_type = game_type
	end
	
end
