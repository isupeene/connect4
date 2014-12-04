
require 'gtk2'
require_relative 'stat'

class LeaderboardDialog
	@@column_names = {0 => "Player Name", 1 => "Wins", 2 => "Losses", 3 => "Ties", 4 => "Win/Loss Ratio"}
	
	def initialize
		@builder = Gtk::Builder::new
		@builder.add_from_file("implementation/LeaderboardDialog.glade")
		@builder.connect_signals{ |handler| method(handler) } 
			
		@leaderboard_tree = @builder.get_object("leaderboardtreeview")
		cell = Gtk::CellRendererText.new()
		@@column_names.each{ |id, name|
			column = Gtk::TreeViewColumn.new(name, cell, :text => id)
			column.set_sort_column_id(id)
			@leaderboard_tree.append_column(column)
		}
		@leaderboard_dialog = @builder.get_object("leaderboarddialog")
		@leaderboard_dialog.signal_connect( "delete-event" ) { @leaderboard_dialog.hide }
		@leaderboard_list = @builder.get_object("leaderboardliststore")
	end
	
	def run(game_type, stats)
		@leaderboard_dialog.set_title(game_type + " Leaderboard")
		@leaderboard_list.clear
		stats.each { |x|
			iter = @leaderboard_list.append
			@leaderboard_list.set_value(iter, 0, x.name)
			@leaderboard_list.set_value(iter, 1, x.wins)
			@leaderboard_list.set_value(iter, 2, x.losses)
			@leaderboard_list.set_value(iter, 3, x.ties)
			@leaderboard_list.set_value(iter, 4, x.win_loss_ratio)
		}
		
		@leaderboard_dialog.run
		@leaderboard_dialog.hide
	end
end