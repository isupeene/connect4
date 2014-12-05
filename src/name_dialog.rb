
require 'gtk2'

class NameDialog
	def initialize
		@builder = Gtk::Builder::new
		@builder.add_from_file("implementation/NameDialog.glade")
		@builder.connect_signals{ |handler| method(handler) } 
			
		@name_dialog = @builder.get_object("namedialog")
		@name_dialog.signal_connect( "delete-event" ) { @name_dialog.hide }
		@name_entry = @builder.get_object("nameentry")
	end
	
	def run(current_name, default_name="Player")
		@name_entry.set_text(current_name)
		response = @name_dialog.run
		
		entered_name = @name_entry.text
		returned_name = ""
		if entered_name.empty? && current_name.empty?
			returned_name = default_name
		elsif response == Gtk::Dialog::RESPONSE_OK
			if entered_name.empty?
				returned_name = current_name
			else
				returned_name = entered_name
			end
		elsif current_name.empty?
			returned_name = default_name
		else
			returned_name = current_name
		end
		@name_dialog.hide
		returned_name
	end
end