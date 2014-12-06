require_relative '../game'
require_relative '../stat'
require_relative 'game_board'
require_relative 'game_result'
require_relative 'database_manager_impl.rb'
require_relative 'victory_conditions'

# Choose victory condition based on game options
def get_victory_condition(game_options)
	if game_options['otto_and_toot']
		Proc.new{ |b| VictoryConditions.otto_and_toot(b) }
	else
		Proc.new{ |b| VictoryConditions.connect4(b) }
	end
end

options = {}
options['player_names'] = ["Bob", "Frank"]
options['current_turn'] = 1
options['otto_and_toot'] = true
options['board'] = GameBoard.new
options['board'][1,2] = 1
a = Game.new(options, &get_victory_condition(options))
db_manager = DatabaseManagerImpl.new
b = db_manager.save_game(a)
if b == 16
	puts "yay"
end

db_manager.save_result(GameResult.new("bob", "frank", 1, 1))
db_manager.save_result(GameResult.new("bob", "frank", 1, 1))
db_manager.save_result(GameResult.new("bob", "cindy", 2, 1))
db_manager.save_result(GameResult.new("bob", "cindy", 0, 1))
db_manager.save_result(GameResult.new("cindy", "bob", 0, 1))
db_manager.save_result(GameResult.new("cindy", "bob", 2, 1))
c = db_manager.leaderboards(1)
puts c.length
c.each{ |d|
	puts d.name
	puts d.wins
	puts d.losses
	puts d.ties
}


