require 'appengine-rack'
AppEngine::Rack.configure_app(
  :application => 'sriram-varahan',
  :version => 1)
require 'guestbook'
run Sinatra::Application
