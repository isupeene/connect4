require_relative 'client'

class RemoteMasterServerImpl < Client
	def target
		"master"
	end
end

