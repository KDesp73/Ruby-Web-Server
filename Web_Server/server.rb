require "socket"
require "active_support/all"

require_relative "request"
require_relative "response"

class Server
    attr_reader :port, :ip, :site_folder, :system_folder

    def initialize(ip, port)
        @ip = ip
        @port = port

        @server = TCPServer.new ip, port    # not readable

        @site_folder = "docs"
        @system_folder = "utils"

        puts "Listening on port #{port}..."

        loop do
            Thread.start(@server.accept) do |client|
                request = Request.new client.readpartial(2048)
                
                response = route(request)
                response.send(client)
        
                client.close
            end
        end
    end

    private
    
    def route(request)
        if request.path == "/" && !File.exists?(File.join(__dir__, @site_folder, "index.html"))     #load system's index.html if user's doesn't exist
            render "index.html", @system_folder 
        elsif request.path == "/"
            render "index.html"
        elsif !File.exists?(File.join(__dir__, @site_folder, request.path))
            render "404.html", @system_folder
        else
            render request.path
        end
    end

    private

    def render(filename, folder = @site_folder)
        full_path = File.join(__dir__, folder, filename)
        if File.exists?(full_path)
            Response.new(code: 200, body: File.binread(full_path))
        else
            Response.new(code: 404, body: File.binread(full_path))
        end
    end
end

port = ENV.fetch("PORT", 2000).to_i
ip = "localhost"
server = Server.new(ip, port)










