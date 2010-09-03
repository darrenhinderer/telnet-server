require 'singleton'

class ConnectionManager
 include Singleton

  def initialize
    @connections = []
  end

  def add_connection(connection)
    broadcast(connection.to_s + " has joined the server")
    @connections << connection
  end

  def remove_connection(connection)
    @connections.delete_if {|c| c.to_s == connection.to_s}
    broadcast(connection.to_s + " has left the server")
  end

  def broadcast(str)
    @connections.each { |connection| connection.send_line(str) }
  end

end
