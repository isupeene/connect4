require_relative 'contracts/contract_decorator'
require_relative 'contracts/controller_contract'
require_relative 'implementation/controller_impl'

# Class to create a controller implementation and decorate it with contracts
class Controller
	include ClassContractDecorator
	include ControllerContract
	
	# Create implementation and decorate it with contracts
	def initialize(*args, &block)
		super(ControllerImpl.send(:new, *args, &block))
	end
end