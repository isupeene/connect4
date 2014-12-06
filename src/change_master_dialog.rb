
require 'gtk2'

class ChangeMasterDialog
	def initialize
		@builder = Gtk::Builder::new
		@builder.add_from_file("implementation/ChangeMasterDialog.glade")
		@builder.connect_signals{ |handler| method(handler) } 
			
		@name_dialog = @builder.get_object("namedialog")
		@name_dialog.signal_connect( "delete-event" ) { @name_dialog.hide }
		@name_entry = @builder.get_object("nameentry")
	end
	
	def run()
		@name_entry.set_text("")
		response = @name_dialog.run
		
		entered_name = @name_entry.text
		returned_name = ""
		if response == Gtk::Dialog::RESPONSE_OK
			returned_name = entered_name
		end
		@name_dialog.hide
		returned_name
	end
end