require_relative 'contracts/contract_decorator'
require_relative 'contracts/game_contract'
require_relative 'implementation/game_impl'

# Class to create a controller implementation and decorate it with contracts
class Game
	include ClassContractDecorator
	include GameContract
	
	# Create implementation and decorate it with contracts
	def initialize(*args, &block)
		super(GameImpl.send(:new, *args, &block))
	end
end