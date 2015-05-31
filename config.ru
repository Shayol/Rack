require "bundler"
require "bundler/setup"
require "codebreaker"
require "rack"
require './models/User'
require './models/Game'
require './app'
require "./lib/Racker"
use Rack::Static, :urls => ["/css"], :root => "public"
run Racker.new