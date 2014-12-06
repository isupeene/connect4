require_relative 'client'
require_relative 'remote_controller_impl' # TODO: No impl

class RemoteGameManagerImpl < Client
	def target
		"game_server"
	end

	def start_game(game_options)
		connection_info = super
		return [RemoteControllerImpl.new(connection_info)]
	end
end

