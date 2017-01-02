# coding: utf-8

module Lerk
  module Config
    DISCORD_CLIENT_ID    = ENV.fetch('DISCORD_CLIENT_ID')
    DISCORD_TOKEN        = ENV.fetch('DISCORD_TOKEN')
    LERK_COMMAND_PREFIX  = ENV.fetch('LERK_COMMAND_PREFIX', '!')
    STEAM_WEB_API_KEY    = ENV.fetch('STEAM_WEB_API_KEY', '')

    # Defaults to 2/s
    HIVE2_RATE_LIMIT     = ENV.fetch('HIVE2_RATE_LIMIT', 2).to_i
    HIVE2_RATE_TIME_SPAN = ENV.fetch('HIVE2_RATE_TIME_SPAN', 1).to_i
  end
end
