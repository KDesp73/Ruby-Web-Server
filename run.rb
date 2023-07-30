require "socket"
require "yaml"
require "active_support/all"


require_relative "src/server"

$config = YAML.load_file "config.yml"

port = ENV.fetch("PORT", $config['port']).to_i
ip = $config['ip']
server = Server.new(File.join(__dir__, "docs"), ip, port)
server.run
