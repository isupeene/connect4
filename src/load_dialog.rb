
require 'gtk2'

class LoadDialog
	def initialize
		@builder = Gtk::Builder::new
		@builder.add_from_file("implementation/LoadDialog.glade")
		@builder.connect_signals{ |handler| method(handler) } 
			
		@load_tree = @builder.get_object("loadtreeview")
		cell = Gtk::CellRendererText.new()
		column = Gtk::TreeViewColumn.new("Game Id", cell, :text => 0)
		column.set_sort_column_id(0)
		@load_tree.append_column(column)
		@load_dialog = @builder.get_object("loaddialog")
		@load_dialog.signal_connect( "delete-event" ) { @load_dialog.hide }
		@load_list = @builder.get_object("loadliststore")
	end
	
	def run(ids)
		@load_list.clear
		ids.each { |x|
			iter = @load_list.append
			@load_list.set_value(iter, 0, x)
		}
		
		response = @load_dialog.run
		id = -1
		if response == Gtk::Dialog::RESPONSE_OK
			choice = @load_tree.selection.selected
			unless choice.nil?
				puts choice[0]
				id = choice[0]
				puts "Load successful"
			end
		end
		@load_dialog.hide
		return id
	end
end