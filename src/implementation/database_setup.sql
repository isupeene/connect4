CREATE TABLE IF NOT EXISTS SavedGames
(
GameId int NOT NULL AUTO_INCREMENT,
Player1 varchar(255) NOT NULL,
Player2 varchar(255) NOT NULL,
CurrentTurn int NOT NULL,
GameType int NOT NULL,
Board char(255) NOT NULL,
PRIMARY KEY (GameId)
) ;

CREATE TABLE IF NOT EXISTS Results
(
GameId int NOT NULL AUTO_INCREMENT,
Player1 varchar(255) NOT NULL,
Player2 varchar(255) NOT NULL,
Winner int NOT NULL,
GameType int NOT NULL,
PRIMARY KEY (GameId)
)
