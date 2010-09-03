class TelnetShell

  def initialize(connection)
    @connection = connection
  end

  def process_response(data)
    if data.downcase.include?("quit")
      @connection.disconnect
      return
    end

    output = `#{data}`
    @connection.send_prompt(output)
    send_prompt
  end

  def start
    send_prompt
  end

  private

  def send_prompt
    @connection.send_prompt("$ ")
  end

end
