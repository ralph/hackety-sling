require 'sinatra/base'
require 'sinatra/hackety_sling'

class TestApp < Sinatra::Base
  register Sinatra::HacketySling
end
