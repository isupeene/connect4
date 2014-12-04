
require 'gtk2'

class MessageDialog
	def initialize
		@builder = Gtk::Builder::new
		@builder.add_from_file("implementation/MessageDialog.glade")
		@builder.connect_signals{ |handler| method(handler) } 
			
		@message_dialog = @builder.get_object("messagedialog")
		@message_dialog.signal_connect( "delete-event" ) { @message_dialog.hide }
	end
	
	def run(message)
		@message_dialog.set_text(message)
		@message_dialog.run
		@message_dialog.hide
	end
end