require_relative 'contracts/contract_decorator'
require_relative 'contracts/view_contract'
require_relative 'implementation/ai_view_impl'

# Class to create an AI view implementation and decorate it with contracts
class AIView
	include ClassContractDecorator
	include ViewContract
	
	# Create implementation and decorate it with contracts
	def initialize(*args, &block)
		super(AIViewImpl.send(:new, *args, &block))
	end
end