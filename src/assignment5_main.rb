# Group 4 Members Isaac Supeene and Braeden Soetaert

# Requirements:
# Ruby version 1.9.3
# Gtk2 version 2.16

require_relative "gui_client"
require_relative "cli_client"

puts "Due to the nature of the assignment, most of this file will be comments as everything" + \
" is accessed through clients which are not set to be easily accessed by a ruby file."
puts "The CLI client can be run from a ruby file using passed input and output streams" + \
" but this case is not the intended use case."

#######
# GUI #
#######

# Start a new GUI client by running the following:
# > ruby gui_client.rb

# A 2-player, connect 4 game will start up by default.
# Player turn and colour are displayed in the bottom right.
# On player's turn click on any of the spaces to place a token in that column.
# Victory is achieved when either Player gets 4 in a row.

# CHOOSING GAME TYPE
# The next game's type can be changed from the Edit menu in the menu bar.
# Only 1 game mode can be selected at a time. This selection effects the next
# game and has no impact on the current game.

# STARTING A NEW GAME
# A new game can be started from the File menu in the menu bar.
# The New option will create a new game when you choose from its submenus.
# The submenus of New determine whether a new single player or mutliplayer
# game will be started. 

# SAVING/LOADING A GAME
# A game can be saved by pressing either Save or Save as from the File menu.
# Only 1 game can be saved currently and a new save overwrites the old one.
# The game can later be loaded through the Open option in the File menu.
# Loading a game will end the current game.

# OTTO AND TOOT VARIANT
# If otto and toot is selected from the edit menu, then an otto and toot game will start.
# Player 1 plays O's and tries to spell 'OTTO' while either Player 2 or the AI plays T's
# and tries to spell the word 'TOOT'

#######
# CLI #
#######

# Start a CLI server by running the following:  
# > irb
# > require "./implementation/master_server_impl"
# > master_server = MasterServerImpl.new

# And kill the server by calling destroy on the server object.
# > master_server.destroy

# Start a new CLI client by running the following:
# > irb
# > require "./cli_client"
# > CLIClient.new

# STARTING A NEW GAME
# Start a new game with the following command:
# > start -s -o
# Both options are optional. -s will make a single player game.
# -o will make an otto and toot game instead of connect 4.

# SHOW LEADERBOARDS
# > show-leaderboards

# START NEW SERVER
# > open-server

# LIST SERVERS
# > list-servers

# JOIN SERVER
# 1 is server id found from list-servers
# > join-server 1

# LEAVE SERVER
# > leave-server

# LIST SAVED GAMES
# > list-saved-games

# SET MASTER SERVER
# set to look for master server at given ip.
# > set-master "127.0.1.1"

# PLACING A TOKEN
# Once a game is started, place a token by typing a zero-based column number (0-6).
# > 0
# places a token in the left-most column.

# SAVING A GAME
# Save the current game with:
# > save
# Only 1 game can be saved at a time and a new save will overwrite the old one.

# LOADING A GAME
# Load the saved game if there is one. 
# 1 is game id found from list-saved-games
# > load 1
# Loading a game will end the current game.

# ENDING A GAME
# End the current game with:
# > quit
# This will end the current game but not the program.

# EXITING THE PROGRAM
# Exit the program with
# > exit
# This will end the current game and exit the program.

# OTTO AND TOOT VARIANT
# Player 1 plays O's and tries to spell 'OTTO' while either Player 2 or the AI plays T's
# and tries to spell the word 'TOOT' 
