require 'thread'

class Connect4AI
	def initialize(view, controller)
		@view = view
		@controller = controller

		main = Thread.new{ main_loop }
		main.priority = 2
	end

	def main_loop
		loop {
			update = @view.updates.pop
			return if update[:game_over]

			if @controller.my_turn
				board = update[:board]
				valid_options = board.width.times.select { |j|
					board.number_of_tokens(j) < board.height
				}
				@controller.play(
					valid_options[rand(valid_options.length)]
				)
			end
		}
	end
end

