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

require 'yaml'

DEBUG = false

class Response
  def initialize(code:, body: '', headers: {})
    @code = code
    @body = body
    @headers = headers
  end

  def send(client)
    client.print "HTTP/1.1 #{@code} #{match_status_message(@code)}\r\n"
    @headers.each do |name, value|
      client.print "#{name}: #{value}\r\n"
    end
    client.print "\r\n"
    client.print @body if @body.present?

    puts "-> #{@code}\r\n" if DEBUG
  end

  private

  def match_status_message(code)
    messages = YAML.load_file File.expand_path('../status_messages.yml', __FILE__)
    messages[code]
  end
end
