
require 'gtk2'

class AboutDialog
	def initialize
		@builder = Gtk::Builder::new
		@builder.add_from_file("implementation/AboutDialog.glade")
		@builder.connect_signals{ |handler| method(handler) } 
			
		@about_dialog = @builder.get_object("aboutdialog")
		@about_dialog.signal_connect( "delete-event" ) { @about_dialog.hide }
	end
	
	def run()
		@about_dialog.run
		@about_dialog.hide
	end
end