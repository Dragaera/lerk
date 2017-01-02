#! /usr/bin/env ruby
# encoding: utf-8

if ENV.fetch('DEVELOPMENT', false)
  require 'dotenv'
  Dotenv.load
end

require 'lerk'

lerk = Lerk::Lerk.new(
  client_id:         Lerk::Config::DISCORD_CLIENT_ID,
  token:             Lerk::Config::DISCORD_TOKEN,
  steam_web_api_key: Lerk::Config::STEAM_WEB_API_KEY,
  prefix:            Lerk::Config::LERK_COMMAND_PREFIX,
)
puts "Invite me: #{ lerk.invite_url }"
lerk.run
