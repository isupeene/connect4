require 'mysql'
require_relative '../game'
require_relative 'game_board'
require_relative 'game_result'
require_relative '../stat'
require_relative 'victory_conditions'

class DatabaseManagerImpl
	
	def initialize
		@db = Mysql.new("mysqlsrv.ece.ualberta.ca", "ece421grp4" , "c2gJvmVo", "ece421grp4", 13010)
		#May need to close this somehow when server ends.
	end
	
	def save_game(game)
		if game.id > 0
			@db.query("INSERT INTO SavedGames (GameId, Player1, Player2, CurrentTurn, GameType, Board)
				VALUES
				( #{game.id}, 
				'#{game.player_names[0]}', 
				'#{game.player_names[1]}', 
				#{game.current_turn}, 
				#{game.game_type}, 
				'#{game.board.to_s}' )
				ON DUPLICATE KEY UPDATE  
					Player1=VALUES(Player1), 
					Player2=VALUES(Player2), 
					CurrentTurn=VALUES(CurrentTurn),
					Board=VALUES(Board)"
			)
			if @db.affected_rows == 1
				return game.id
			end
		end
		return -1
	end

	# Can be called after initialization as for what GameId to start after.
	def largest_id
		max_in_saves = 0
		max_in_results = 0
		res = @db.query("SELECT MAX(GameId) as MaxId FROM SavedGames")
		res.each_hash{|row|
			max_in_saves = row['MaxId']
		}
		res.free
		res = @db.query("SELECT MAX(GameId) as MaxId FROM Results")
		res.each_hash{|row|
			max_in_results = row['MaxId']
		}
		res.free
		return [max_in_saves, max_in_results].max
	end
	
	def load_game(id)
		res = @db.query("SELECT * FROM SavedGames WHERE GameId=#{id}")
		old_game = nil
		if @db.affected_rows == 1
			res.each_hash{ |row|
				old_game = row_to_game(row)
			}
			@db.query("DELETE FROM SavedGames
				WHERE GameId=#{id}")
		end
		res.free
		return old_game
	end
	
	def row_to_game(row)
		options = {}
		options[:id] = row['GameId'].to_i
		options[:player_names] = [row['Player1'], row['Player2']]
		options[:current_turn] = row['CurrentTurn'].to_i
		if row['GameType'].to_i == 2
			options[:otto_and_toot] = true
		end
		options[:board] = GameBoard.load(row['Board'])
		return Game.new(options, &get_victory_condition(options))
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
	
	def save_result(game_result)
		if game_result.id > 0
			@db.query("INSERT INTO Results (GameId, Player1, Player2, Winner, GameType)
				VALUES
				(#{game_result.id}, 
				'#{game_result.player1}',  
				'#{game_result.player2}', 
				#{game_result.winner}, 
				#{game_result.game_type} )"
			)
			if @db.affected_rows == 1
				return game_result.id
			end
		end
		return -1
	end
	
	def get_result(id)
		res = @db.query("SELECT * FROM Results WHERE GameId=#{id}")
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
		GameResult.new(row['GameId'].to_i, row['Player1'], row['Player2'], row['Winner'].to_i, row['GameType'].to_i)
	end
	
	def get_results
		res = @db.query("SELECT * FROM Results")
		results = []
		res.each_hash{ |row|
			results << row_to_result(row)
		}
		res.free
		return results
	end
	
	def leaderboards(game_type)
		@db.query("DROP TABLE IF EXISTS Player1")
		@db.query("DROP TABLE IF EXISTS Player2")
		@db.query("CREATE TABLE Player1 AS 
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
		@db.query("CREATE TABLE Player2 AS 
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
				p1.Player as Player,
				(p1.Wins + IFNULL(p2.Wins,0)) as Wins,
				(p1.Losses + IFNULL(p2.Losses,0)) as Losses,
				(p1.Ties + IFNULL(p2.Ties,0)) as Ties 
			FROM Player1 as p1
			LEFT OUTER JOIN Player2 as p2
			ON p1.Player=p2.Player 
			UNION ALL
			SELECT 
				p2.Player as Player,
				p2.Wins as Wins,
				p2.Losses as Losses,
				p2.Ties as Ties 
			FROM Player1 as p1 
			RIGHT OUTER JOIN Player2 as p2 
			ON p1.Player=p2.Player 
			WHERE p1.Player is null
			ORDER BY Wins DESC"
		)
		
		rankings = []
		res.each_hash{|row|
			rankings << Stat.new(row['Player'], row['Wins'].to_i, row['Losses'].to_i, row['Ties'].to_i)
		}
		res.free
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
