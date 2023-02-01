require "socket"
require "active_support/all"

require_relative "request"
require_relative "response"

port = ENV.fetch("PORT", 2000).to_i
ip = "localhost"
server = TCPServer.new ip, port
@site_folder = "docs"
@system_folder = "utils"

puts "Listening on port #{port}..."

def route(request)
    if request.path == "/" && !File.exists?(File.join(__dir__, @site_folder, "index.html"))
        render "index.html", @system_folder 
    elsif request.path == "/"
        render "index.html"
    elsif !File.exists?(File.join(__dir__, @site_folder, request.path))
        render "404.html", @system_folder
    else
        render request.path
    end
end

def render(filename, folder = @site_folder)
    full_path = File.join(__dir__, folder, filename)
    if File.exists?(full_path)
        Response.new(code: 200, body: File.binread(full_path))
    else
        Response.new(code: 404, body: File.binread(full_path))
    end
end



loop do
    Thread.start(server.accept) do |client|
        request = Request.new client.readpartial(2048)
        
        response = route(request)
        response.send(client)

        client.close
    end
end

