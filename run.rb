#!/usr/bin/env ruby

require 'socket'
require 'yaml'
require 'active_support/all'

require_relative 'src/server'

$config = YAML.load_file File.join(__dir__, 'config.yml')

port = ENV.fetch('PORT', $config['port']).to_i
ip = $config['ip']
dir = '/'

if ARGV.empty?
  dir = '.'
elsif ARGV.length > 1
  abort 'One argument is needed'
else
  dir = ARGV[0]
end

server = Server.new(dir, ip, port)
server.run
