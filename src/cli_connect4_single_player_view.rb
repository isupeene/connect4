require_relative 'contracts/contract_decorator'
require_relative 'contracts/view_contract'
require_relative 'implementation/cli_connect4_single_player_view_impl'

# Class to create a command line interface connect 4 single player view implementation and decorate it with contracts
class CLIConnect4SinglePlayerView
	include ClassContractDecorator
	include ViewContract
	
	# Create implementation and decorate it with contracts
	def initialize(*args, &block)
		super(CLIConnect4SinglePlayerViewImpl.send(:new, *args, &block))
	end
end