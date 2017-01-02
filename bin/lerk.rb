#! /usr/bin/env ruby
# encoding: utf-8

require 'lerk'

lerk = Lerk::Lerk.new(
  client_id: Lerk::Config::DISCORD_CLIENT_ID,
  token:     Lerk::Config::DISCORD_TOKEN,
  prefix:    Lerk::Config::LERK_COMMAND_PREFIX
)
puts "Invite me: #{ lerk.invite_url }"
lerk.run
