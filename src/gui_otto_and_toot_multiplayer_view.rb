require_relative 'contracts/contract_decorator'
require_relative 'contracts/view_contract'
require_relative 'implementation/gui_otto_and_toot_multiplayer_view_impl'

# Class to create a graphical user interface otto and toot multiplayer view implementation and decorate it with contracts
class GUIOttoAndTootMultiplayerView
	include ClassContractDecorator
	include ViewContract
	
	# Create implementation and decorate it with contracts
	def initialize(*args, &block)
		super(GUIOttoAndTootMultiplayerViewImpl.send(:new, *args, &block))
	end
end