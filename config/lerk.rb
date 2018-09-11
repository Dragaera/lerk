# coding: utf-8

$stdout.sync = true

module Lerk
  module Config
    VALID_LOG_LEVELS = [:debug, :verbose, :normal, :quiet, :silent]

    DISCORD_CLIENT_ID   = ENV.fetch('DISCORD_CLIENT_ID')
    DISCORD_TOKEN       = ENV.fetch('DISCORD_TOKEN')

    LOG_LEVEL           = ENV.fetch('LOG_LEVEL', 'normal').to_sym
    unless VALID_LOG_LEVELS.include? LOG_LEVEL
      raise ArgumentError, "LOG_LEVEL '#{ LOG_LEVEL }' invalid. Valid values are: #{ VALID_LOG_LEVELS.join(', ') }"
    end

    module Lerk
      COMMAND_PREFIX = ENV.fetch('LERK_COMMAND_PREFIX', '!')

      ADMIN_USERS = ENV.fetch('LERK_ADMIN_USERS', '').split(',').map do |id|
        raise ArgumentError, "ADMIN_USERS must contain numeric IDs only!" unless id.match(/^\d+$/)
        id.to_i
      end

      HINTS_ADMIN_USERS = ENV.fetch('LERK_HINTS_ADMIN_USERS', '').split(',').map do |id|
        raise ArgumentError, "HINTS_ADMIN_USERS must contain numeric IDs only!" unless id.match(/^\d+$/)
        id.to_i
      end
    end

    module Prometheus
      PORT = ENV.fetch('PROMETHEUS_PORT', 5000).to_i
      LISTEN_IP = ENV.fetch('PROMETHEUS_LISTEN_IP', '0.0.0.0')
      ENABLED = ENV.fetch('PROMETHEUS_ENABLED', 'true') == 'true'
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

      ENABLE_EMBEDS = ['true', 'yes', '1'].include?(ENV.fetch('HIVE_ENABLE_EMBEDS', 'true'))
    end

    module Observatory
      BASE_URL = ENV.fetch('OBSERVATORY_BASE_URL', 'https://observatory.morrolan.ch')
    end

    module Excuse
      MAXIMUM_AMOUNT = ENV.fetch('EXCUSE_MAXIMUM_AMOUNT', 10).to_i
      PER_USER_RATE_LIMIT     = ENV.fetch('EXCUSE_PER_USER_RATE_LIMIT', 20).to_i
      PER_USER_RATE_TIME_SPAN = ENV.fetch('EXCUSE_PER_USER_RATE_TIME_SPAN', 60).to_i
    end

    module CalendarFacts
      PER_USER_RATE_LIMIT     = ENV.fetch('CALENDAR_FACTS_PER_USER_RATE_LIMIT', 5).to_i
      PER_USER_RATE_TIME_SPAN = ENV.fetch('CALENDAR_FACTS_PER_USER_RATE_TIME_SPAN', 60).to_i
    end

    module Gorge
      BASE_URL            = ENV['GORGE_BASE_URL']
      HTTP_BASIC_USER     = ENV['GORGE_HTTP_BASIC_USER']
      HTTP_BASIC_PASSWORD = ENV['GORGE_HTTP_BASIC_PASSWORD']
      CONNECT_TIMEOUT     = ENV.fetch('GORGE_CONNECT_TIMEOUT', 1).to_i
      TIMEOUT             = ENV.fetch('GORGE_TIMEOUT', 2).to_i
    end

    module Statistics
      SHOW_TOPMOST_N = ENV.fetch('STATISTICS_SHOW_TOPMOST_N', '5').to_i
    end

    module Hints
      SNARKY_COMMENT_CHANCE = ENV.fetch('HINTS_SNARKY_COMMENT_CHANCE', '100').to_i
    end

    module Database
      ADAPTER  = 'postgres'
      HOST     = ENV['DB_HOST']
      PORT     = ENV['DB_PORT']
      DATABASE = ENV.fetch('DB_DATABASE')
      USER     = ENV['DB_USER']
      PASS     = ENV['DB_PASS']
    end
  end
end
