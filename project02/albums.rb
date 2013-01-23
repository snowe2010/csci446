require 'rack'

class HelloWorld
  def call(env)
    [200, {"Content-Type" => "text/plain"}, ["Hello from Rack!"]]
  end
end

Rack::Handler::WEBrick.run HelloWorld.new, :Port => 8080