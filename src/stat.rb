class Stat
	
	attr_accessor :name
	attr_accessor :wins
	attr_accessor :losses
	attr_accessor :ties
	
	def initialize(name, wins=0, losses=0, ties=0)
		@name = name
		@wins = wins.to_f
		@losses = losses.to_f
		@ties = ties.to_f
	end
	
	def win_loss_ratio
		if @losses == 0
			0
		else
			@wins / @losses
		end
	end
end