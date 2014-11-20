require_relative 'contracts/contract_decorator'
require_relative 'contracts/view_contract'
require_relative 'implementation/gui_otto_and_toot_single_player_view_impl'

# Class to create a graphical user interface otto and toot single player view implementation and decorate it with contracts
class GUIOttoAndTootSinglePlayerView
	include ClassContractDecorator
	include ViewContract
	
	# Create implementation and decorate it with contracts
	def initialize(*args, &block)
		super(GUIOttoAndTootSinglePlayerViewImpl.send(:new, *args, &block))
	end
end