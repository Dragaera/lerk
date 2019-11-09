require 'sinatra/base'

module Lerk
  module Web
    class Interface < Sinatra::Base
      set :sessions, true
      set :views, settings.root + '/views'

      get '/oauth' do
        haml :oauth
      end
    end
  end
end
