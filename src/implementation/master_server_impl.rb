require_relative 'game_server_impl' # TODO: no impl
require_relative 'database_manager_impl'

require 'xmlrpc/server'
require 'socket'

class MasterServerImpl

	MAX_SERVERS = 10

	def initialize
		@game_servers = [nil]*MAX_SERVERS
		@server = XMLRPC::Server.new(50550)
		@server.add_handler("master", self)
		Thread.new{ @server.serve }
		@database = DatabaseManagerImpl.new
	end

	def shutdown
		@game_servers.compact.each{ |s| s.shutdown }
		@server.shutdown
	end

	def first_available_id
		@game_servers.index{ |g| g.nil? }
	end

	def open_server(player)
		# Definitely not thread-safe.

		id = first_available_id
		return nil unless id

		@game_servers[id] = GameServerImpl.new(id, player, self)

		return {
			"hostname" => Socket.gethostname,
			"port" => @game_servers[id].port
		}
	end

	def server_list
		@game_servers.select{ |g| !g.nil? }.map{ |s| summarize(s) }
	end

	def summarize(server)
		{
			"id" => server.id,
			"number_of_players" => server.number_of_players,
			"port" => server.port
		}
	end

	def leaderboards(game_type)
		begin
			@database.leaderboards(game_type)
		rescue Exception => ex
			puts ex.message
			puts ex.backtrace
			raise ex
		end
	end

	def ping
		return true
	end

	def notify(id)
		# This is likely to cause concurrency issues,
		# because we will be able to immediately
		# reassign the now-unused port, even though
		# it will take a few seconds for the OS to make
		# that port available again.
		@game_servers[id] = nil
	end

end

