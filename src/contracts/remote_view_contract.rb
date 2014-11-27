require_relative "view_contract.rb"

module RemoteViewContract
	include ViewContract

	def invariant
		super
		assert(respond_to?(:ping))
	end
end

