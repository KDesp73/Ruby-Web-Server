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

class Request
    attr_reader :method, :path, :headers, :body, :query

    def initialize(request)
        lines = request.lines
        index = lines.index("\r\n")
        
        @method, @path, _ = lines.first.split
        @path, @query = @path.split("?")
        @headers = parse_headers(lines[1...index])
        @body = lines[(index + 1)..-1].join

        puts "<- GET #{@path}"
    end

    def parse_headers(lines)
        headers = {}
    
        lines.each do |line|
          name, value = line.split(": ")
          headers[name] = value.chomp
        end
    
        return headers
    end

    def content_length
        headers["Content-Length"].to_i
    end
end