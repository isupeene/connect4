require 'thread'

class AIViewImpl
	def initialize
		@updates = Queue.new
	end

	attr_reader :updates

	def turn_update(board)
		@updates.push({:board => board})
	end

	def game_over(winner)
		@updates.push({:game_over => true, :winner => winner})
	end
end

