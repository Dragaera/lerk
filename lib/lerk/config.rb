# coding: utf-8

module Lerk
  module Config
    DISCORD_CLIENT_ID   = ENV.fetch('DISCORD_CLIENT_ID')
    DISCORD_TOKEN       = ENV.fetch('DISCORD_TOKEN')
    LERK_COMMAND_PREFIX = ENV.fetch('LERK_COMMAND_PREFIX', '!')
    STEAM_WEB_API_KEY   = ENV.fetch('STEAM_WEB_API_KEY', '')
  end
end
