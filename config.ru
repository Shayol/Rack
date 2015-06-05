require "bundler"
require "bundler/setup"
require "codebreaker"
require "rack"
require "./lib/Racker"
use Rack::Static, :urls => ["/css", "/js"], :root => "public"
use Rack::Session::Cookie, :key => 'rack.session',
                           :secret => 'secret'
run Racker