gem "test-unit"
require 'test/unit'

module ViewContract
	def invariant
		assert(respond_to?(:turn_update))
	end
end
