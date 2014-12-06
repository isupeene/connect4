require_relative 'game_board'
require_relative 'client'

class RemoteViewImpl < Client
	def target
		"view"
	end
end

