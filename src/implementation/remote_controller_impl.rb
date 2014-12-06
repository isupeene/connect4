require_relative 'client'

class RemoteControllerImpl < Client
	def target
		"controller"
	end
end

