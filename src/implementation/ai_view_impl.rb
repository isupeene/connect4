require 'thread'

class AIViewImpl
	# Set up queue for AI player to read updates from.
	def initialize
		@updates = Queue.new
	end

	attr_reader :updates

	# Callback for game model to call when game changes.
	# Pushes update to the AI player.
	def turn_update(update)
		@updates.push(update)
	end
end

