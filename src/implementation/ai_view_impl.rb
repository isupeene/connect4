require 'thread'

class AIViewImpl
	def initialize
		@updates = Queue.new
	end

	attr_reader :updates

	def turn_update(update)
		@updates.push(update)
	end
end

