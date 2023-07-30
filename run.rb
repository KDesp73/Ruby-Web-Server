#!/usr/bin/env ruby

require "socket"
require "yaml"
require "active_support/all"


require_relative "src/server"

$config = YAML.load_file "config.yml"

port = ENV.fetch("PORT", $config['port']).to_i
ip = $config['ip']

if ARGV.length != 1
  abort "One argument is needed";
end

server = Server.new(ARGV[0], ip, port)
server.run
