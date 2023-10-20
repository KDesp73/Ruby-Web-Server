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

require 'socket'
require 'active_support/all'
require 'yaml'

require_relative 'request'
require_relative 'response'
require_relative 'print'

$config = YAML.load_file File.expand_path("../../config.yml", __FILE__)

class Server
  attr_reader :site_folder, :port, :ip

  def initialize(folder, ip, port)
    @ip = ip
    @port = port
    @server = TCPServer.new ip, port # not readable
    @site_folder = folder
    @system_folder = File.expand_path('../utils', __dir__)
  end

  def run
    print_on_start
    loop do
      Thread.start(@server.accept) do |client|
        begin
          request = Request.new client.readpartial(2048)
        rescue EOFError
          request = nil
        end

        response = route(request)
        response.send(client)

        client.close
      end
    end
  end

  def route(request)
    return if request.nil?

    if request.path == '/' && !File.exist?(File.join(@site_folder, 'index.html')) # load system's index.html if user's doesn't exist
      render @system_folder, 'index.html'
    elsif request.path == 'favicon.ico' && !File.exist?(File.join(@site_folder, 'favicon.ico'))
      render @system_folder, 'favicon.ico'
    elsif request.path == '/'
      render 'index.html'
    else
      render request.path
    end
  end

  def render(folder = @site_folder, filename)
    # headers according to the http protocol
    http_headers = { 'Date' => "#{Time.utc(*Time.new.to_a)}",'Server' => $config['server_name'] }
    full_path = File.join(folder, filename)

    if File.exist?(full_path)
      body = File.binread(full_path)
      http_headers.merge!('Content-Type' => get_ext(filename))
      http_headers.merge!('Content-Length' => body.length)

      Response.new(code: 200, body: body, headers: http_headers)
    else
      htaccess_path = File.join(@site_folder, '.htaccess')

      if htaccess_exists?(htaccess_path)
        body = File.binread(File.join(@site_folder, get_404_page))
      else
        body = File.binread(File.join(@system_folder, '404.html'))
      end
      http_headers.merge!('Content-Length' => body.length)
      Response.new(code: 404, body: body, headers: http_headers)

    end
  end

  def htaccess_exists?(htaccess_path)
    return false unless File.exist?(htaccess_path)
    return false unless File.exist?(File.join(@site_folder, get_404_page))

    true
  end

  private

  def get_404_page
    htaccess_path = File.join(@site_folder, '.htaccess')

    htaccess_content = File.binread(htaccess_path)
    htaccess_content.slice(htaccess_content.index('ErrorDocument 404') + 'ErrorDocument 404'.length + 1, htaccess_content.length-1)
  end

  private

  def get_ext(file)
    return 'text/html' if File.extname(file) == '.html'
    return 'text/css' if File.extname(file) == '.css'
    return 'text/javascript' if File.extname(file) == '.js'

    return 'image/svg+xml' if File.extname(file) == '.svg'
    return 'image/jpeg' if File.extname(file) == '.jpg'
    return 'image/png' if File.extname(file) == '.png'
    return 'image/x-icon' if File.extname(file) == '.ico'

    return 'font/ttf' if File.extname(file) == '.ttf'

    return 'video/mp4' if File.extname(file == '.mp4')
  end
end
