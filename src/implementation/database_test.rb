require_relative '../game'
require_relative 'game_board'
require_relative 'database_manager_impl'
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

db_manager.save_result({"Player1" => "bob", "Player2" => "frank", "Winner" => 1, "GameType" => 1})
db_manager.save_result({"Player1" => "bob", "Player2" => "frank", "Winner" => 1, "GameType" => 1})
db_manager.save_result({"Player1" => "bob", "Player2" => "cindy", "Winner" => 2, "GameType" => 1})
db_manager.save_result({"Player1" => "bob", "Player2" => "cindy", "Winner" => 0, "GameType" => 1})
db_manager.save_result({"Player1" => "bob", "Player2" => "frank", "Winner" => 1, "GameType" => 2})
db_manager.save_result({"Player1" => "bob", "Player2" => "frank", "Winner" => 1, "GameType" => 2})
db_manager.save_result({"Player1" => "bob", "Player2" => "cindy", "Winner" => 2, "GameType" => 2})
db_manager.save_result({"Player1" => "bob", "Player2" => "cindy", "Winner" => 0, "GameType" => 2})
c = db_manager.leaderboards(1)
puts c.length
c.each{ |d|
	puts d["Player"]
	puts d["Wins"]
	puts d["Losses"]
	puts d["Ties"]
}
c = db_manager.leaderboards(2)
puts c.length
c.each{ |d|
	puts d["Player"]
	puts d["Wins"]
	puts d["Losses"]
	puts d["Ties"]
}
puts db_manager.saved_game_ids


