require 'sinatra/base'

module Lerk
  module Web
    class Interface < Sinatra::Base
      set :sessions, true
      set :views, settings.root + '/views'

      get '/' do
        haml :index
      end

      get '/oauth' do
        secret = params['state']
        code   = params['code']

        if secret.nil? || code.nil? || secret.empty? || code.empty?
          return haml :oauth_error, locals: { error_msg: 'Invalid or missing parameters.' }
        end

        user = DiscordUser.first(oauth_secret: secret)
        unless user
          return haml :oauth_error, locals: { error_msg: 'Invalid or missing token.' }
        end

        linked_connections = user.link_discord_connections(code: code)
        if linked_connections
          return haml :oauth_success, locals: { linked_connections: linked_connections, discord_user: user }
        else
          return haml :oauth_error, locals: { error_msg: 'Unable to link accounts. Do you have any connected to Discord?' }
        end
      end
    end
  end
end
