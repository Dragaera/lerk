# coding: utf-8

module Lerk
  module Config
    VALID_LOG_LEVELS = [:debug, :verbose, :normal, :quiet, :silent]

    DISCORD_CLIENT_ID   = ENV.fetch('DISCORD_CLIENT_ID')
    DISCORD_TOKEN       = ENV.fetch('DISCORD_TOKEN')
    LERK_COMMAND_PREFIX = ENV.fetch('LERK_COMMAND_PREFIX', '!')

    LOG_LEVEL           = ENV.fetch('LOG_LEVEL', 'normal').to_sym
    unless VALID_LOG_LEVELS.include? LOG_LEVEL
      raise ArgumentError, "LOG_LEVEL '#{ LOG_LEVEL }' invalid. Valid values are: #{ VALID_LOG_LEVELS.join(', ') }"
    end

    module HiveInterface
      STEAM_WEB_API_KEY   = ENV.fetch('STEAM_WEB_API_KEY', '')

      # Defaults to 2/s
      GLOBAL_RATE_LIMIT     = ENV.fetch('HIVE_GLOBAL_RATE_LIMIT', 2).to_i
      GLOBAL_RATE_TIME_SPAN = ENV.fetch('HIVE_GLOBAL_RATE_TIME_SPAN', 1).to_i

      # Defaults to 1/s
      PER_USER_RATE_LIMIT     = ENV.fetch('HIVE_USER_RATE_LIMIT', 1).to_i
      PER_USER_RATE_TIME_SPAN = ENV.fetch('HIVE_USER_RATE_TIME_SPAN', 1).to_i

      # Defaults to 1/5 min
      HELP_MESSAGE_RATE_LIMIT     = ENV.fetch('HIVE_HELP_MESSAGE_RATE_LIMIT', 1).to_i
      HELP_MESSAGE_RATE_TIME_SPAN = ENV.fetch('HIVE_HELP_MESSAGE_RATE_TIME_SPAN', 300).to_i

      PER_USER_RATE_LIMIT_MESSAGE = <<EOF
Hello there!

You have reached the rate limit of Hive 2 queries.
Please wait a few seconds before you issue another query. :)
EOF
    end

    module Excuse
      PER_USER_RATE_LIMIT     = ENV.fetch('EXCUSE_PER_USER_RATE_LIMIT', 20).to_i
      PER_USER_RATE_TIME_SPAN = ENV.fetch('EXCUSE_PER_USER_RATE_TIME_SPAN', 60).to_i
    end
  end
end
