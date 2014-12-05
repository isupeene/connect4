CREATE TABLE `SavedGames` IF NOT EXISTS
(
GameId int NOT NULL,
Player1 varchar(255) NOT NULL,
Player2 varchar(255) NOT NULL,
CurrentTurn int NOT NULL,
GameType int NOT NULL,
Board char(255) NOT NULL,
PRIMARY KEY (GameId)
) ;

CREATE TABLE `Results` IF NOT EXISTS
(
GameId int NOT NULL,
Player1 varchar(255) NOT NULL,
Player2 varchar(255) NOT NULL,
Winner int NOT NULL,
GameType int NOT NULL,
PRIMARY KEY (GameId)
)
