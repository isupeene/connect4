require 'mysql'
require_relative '../game'
require_relative 'game_board'
require_relative 'game_result'
require_relative '../stat'

class DatabaseManagerImpl
	
	def initialize
		@db = Mysql.new("mysqlsrv.ece.ualberta.ca", "ece421grp4" , "c2gJvmVo", "ece421grp4", 13010)
		#May need to close this somehow when server ends.
	end
	
	def save_game(game)
		if game.id > 0
			@db.query("INSERT INTO SavedGames (GameId, Player1, Player2, CurrentTurn, GameType, Board)
				VALUES
				(" + game.id +", '" + 
				game.player_names[0] + "', '" + 
				game.player_names[1] + "', " + 
				game.current_turn + ", " + 
				game.game_type + ", '" + 
				game.board.to_s + "' )"
			)
			if @db.affected_rows == 1
				return game.id
			end
		end
		return -1
	end
	
	def load_game(id)
		res = @db.query("SELECT * FROM SavedGames WHERE GameId=" + id)
		old_game = nil
		if @db.affected_rows == 1
			res.each_hash{ |row|
				old_game = row_to_game(row)
			}
			@db.query("DELETE FROM SavedGames
				WHERE GameId=" + id)
		end
		res.free
		return old_game
	end
	
	def row_to_game(row)
		options = {}
		options[:id] = row['GameId']
		options[:player_names] = [row['Player1'], row['Player2']]
		options[:current_turn] = row['CurrentTurn']
		if row['GameType'] == 2
			options[:otto_and_toot] = true
		end
		options[:board] = GameBoard.load(row['Board'])
		return Game.new(options, [], &get_victory_condition(options))
	end
	
	def saved_games
		res = @db.query("SELECT * FROM SavedGames")
		games = []
		res.each_hash{ |row|
			games << row_to_game(row)
		}
		res.free
		return games
	end
	
	def save_results(game)
		if game.id > 0
			@db.query("INSERT INTO Results (GameId, Player1, Player2, Winner, GameType)
				VALUES
				(" + game.id +", '" + 
				game.player_names[0] + "', '" + 
				game.player_names[1] + "', " + 
				game.get_winner + ", " + 
				game.game_type + ")"
			)
			if @db.affected_rows == 1
				return game.id
			end
		end
		return -1
	end
	
	def get_result(id)
		res = @db.query("SELECT * FROM Results WHERE GameId=" + id)
		game_result = nil
		if @db.affected_rows == 1
			res.each_hash{ |row|
				game_result = row_to_game(row)
			}
		end
		res.free
		return game_result
	end
	
	def row_to_result(row)
		GameResult.new(row['GameId'], row['Player1'], row['Player2'], row['Winner'], row['GameType'])
	end
	
	def get_results
		res = @db.query("SELECT * FROM SavedGames")
		results = []
		res.each_hash{ |row|
			results << row_to_result(row)
		}
		res.free
		return results
	end
	
	def leaderboards(game_type)
		@db.query("DROP TABLE Player1 IF EXISTS")
		@db.query("DROP TABLE Player2 IF EXISTS")
		@db.query("CREATE TEMPORARY TABLE Player1 AS 
			(SELECT 
				Player1 as Player,
				sum(case when Winner = 1 then 1 else 0 end) as Wins,
				sum(case when Winner = 2 then 1 else 0 end) as Losses,
				sum(case when Winner = 0 then 1 else 0 end) as Ties 
			FROM 
				Results 
			GROUP BY 
				Player 
			)"
		)
		@db.query("CREATE TEMPORARY TABLE Player2 AS 
			(SELECT 
				Player2 as Player,
				sum(case when Winner = 2 then 1 else 0 end) as Wins,
				sum(case when Winner = 1 then 1 else 0 end) as Losses,
				sum(case when Winner = 0 then 1 else 0 end) as Ties 
			FROM 
				Results 
			GROUP BY 
				Player 
			)"
		)
		res = @db.query("SELECT 
				(case when Player1.Player = NULL then Player2.Player else Player1.Player end) as Player,
				(Player1.Wins + Player2.Wins) as Wins,
				(Player1.Losses + Player2.Losses) as Losses,
				(Player1.Ties + Player2.Ties) as Ties 
			FROM Player1 
			FULL OUTER JOIN Player2 
			ON Player1.Player=Player2.Player 
			ORDER BY Wins"
		)
		rankings = []
		res.each_hash{|row|
			rankings << Stat.new(row['Player'], row['Wins'], row['Losses'], row['Ties'])
		}
		return rankings
	end
	
	# Choose victory condition based on game options
	def get_victory_condition(game_options)
		if game_options[:otto_and_toot]
			Proc.new{ |b| VictoryConditions.otto_and_toot(b) }
		else
			Proc.new{ |b| VictoryConditions.connect4(b) }
		end
	end

end