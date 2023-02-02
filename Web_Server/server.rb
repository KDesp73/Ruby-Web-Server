# MIT License
# 
# Copyright (c) 2023 Konstantinos Despoinidis
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.



require "socket"
require "active_support/all"
require "yaml"

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


config = YAML.load_file "config.yml" 

port = ENV.fetch("PORT", config['port']).to_i
ip = config['ip']
server = Server.new(ip, port)










