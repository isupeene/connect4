require_relative 'contracts/contract_decorator'
require_relative 'contracts/game_manager_contract'
require_relative 'implementation/game_manager_impl'

# Class to create a controller implementation and decorate it with contracts
class GameManager
	include ClassContractDecorator
	include GameManagerContract
	
	# Create implementation and decorate it with contracts
	def initialize(*args, &block)
		super(GameManagerImpl.send(:new, *args, &block))
	end
end