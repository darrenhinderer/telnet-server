require 'rubygems'
require 'eventmachine'
require 'telnet_auth'
require 'telnet_shell'
require 'ansi'
require 'connection_manager'

class TelnetServer < EM::Connection

  #begin connection callbacks
  def post_init
    send_line("Please login, to signup type \"new\" at the prompt.", :green)
    @telnet_auth = TelnetAuth.new(self) 
    @shell = TelnetShell.new(self)
  end

  def receive_data(data)
    data = remove_newlines(data)
    
    if (@telnet_auth.state != :logged_in)
      @telnet_auth.process_response(data)
    else
      @shell.process_response(data)
    end
  end

  def disconnect
    ConnectionManager.instance.remove_connection(self)
    send_line("Goodbye.", :green)
    close_connection_after_writing
  end
 
  def unbind
    #do any kind of cleanup here
  end
  #end callbacks

  def send_line(data, color=nil)
    send_data(data, color, true)
  end

  def send_prompt(data, color=nil)
    send_data(data, color, false)
  end

  def start_shell
    ConnectionManager.instance.add_connection(self)
    @shell.start
  end

  def to_s
    str = @telnet_auth.username 
    str += " (" + Socket.unpack_sockaddr_in(get_peername)[1].to_s + ")"
  end

  private 

  def send_data(data, color=nil, newline=false)
    if newline
      data = data + "\r\n" 
    end
 
    case color
    when :red
      super(ANSI.red(data))
    when :green
      super(ANSI.green(data))
    else
      super(data)
    end
  end

  def remove_newlines(str)
    str.strip.downcase.gsub('\r\n' , '')
  end

end

ActiveRecord::Base.establish_connection(
  :adapter   => "sqlite3",
  :database => "telnet.db"
)

EM::run {
  EM::start_server("192.168.1.149", 8090, TelnetServer)
  puts "Telnet Server Started"
}
