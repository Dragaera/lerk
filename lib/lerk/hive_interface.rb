# coding: utf-8
require 'benchmark'

require 'silverball'

module Lerk
  module HiveInterface
    extend Silverball::DateTime
    extend Silverball::Numbers

    def self.register(bot, registry: registry)
      @bot = bot
      @registry = registry

      init_rate_limiter
      init_metrics
      bind_commands
    end

    private
    def self.init_rate_limiter
      @rate_limiter = Discordrb::Commands::SimpleRateLimiter.new

      @rate_limiter.bucket(
        :hive_global_api_calls,
        limit:     Config::HiveInterface::GLOBAL_RATE_LIMIT,
        time_span: Config::HiveInterface::GLOBAL_RATE_TIME_SPAN
      )

      @rate_limiter.bucket(
        :hive_per_user_api_calls,
        limit:     Config::HiveInterface::PER_USER_RATE_LIMIT,
        time_span: Config::HiveInterface::PER_USER_RATE_TIME_SPAN
      )

      @rate_limiter.bucket(
        :hive_help_message,
        limit:     Config::HiveInterface::HELP_MESSAGE_RATE_LIMIT,
        time_span: Config::HiveInterface::HELP_MESSAGE_RATE_TIME_SPAN
      )
    end

    def self.init_metrics
      @cmd_counter = @registry.counter(
        :lerk_commands_hive_total,
        'Number of issued `!hive` commands.'
      )

      @query_time = @registry.histogram(
        :lerk_hive_query_duration_seconds,
        'Duration of Hive API calls in seconds'
      )
    end

    def self.bind_commands
      @bot.command(
        [:hive],
        description: 'Retrieve Hive player data',
        usage: '!hive [Steam ID | Default: Discord username]',
        min_args: 0,
        max_args: 1,
      ) do |event, steam_id|
        command_hive(event, steam_id)
      end
    end

    def self.command_hive(event, steam_id)
      if rate_limited?(event)
        @cmd_counter.increment({ status: :rate_limited })
        return
      end

      steam_id ||= event.author.username
      Logger.command(event, 'hive_query', { identifier: steam_id })

      account_id = resolve_account_id(steam_id)
      if account_id.nil?
        msg = "Could not convert #{ steam_id } to account ID, please try another."
        msg << steamid_help_message(event)
        @cmd_counter.increment({ status: :identifier_invalid })
        return msg
      end

      data = get_player_data(account_id)
      if data.nil?
        msg = "Could not retrieve data for ID #{ steam_id } (Account: #{ account_id })."
        msg << steamid_help_message(event)
        @cmd_counter.increment({ status: :no_data_retrieved })
        return msg
      end

      @cmd_counter.increment({ status: :success })
      '%{alias} - Skill: %{skill}, Level: %{level}, Score: %{score}, Playtime: %{playtime} (%{playtime_in_hours})' % {
        alias:             data.alias,
        skill:             self.number_with_separator(data.skill),
        level:             data.level,
        score:             self.number_with_separator(data.score),
        playtime:          self.timespan_in_words(data.time_total),
        playtime_in_hours: self.timespan_in_words(data.time_total, unit: :hours, round: 1),
      }
    end

    def self.resolve_account_id(s)
      begin
        SteamID::SteamID.from_string(s, steam_api_key: Config::HiveInterface::STEAM_WEB_API_KEY)
      rescue WebApiError, ArgumentError => e
        puts "Error: Could not convert #{ s } to account ID: #{ e.message }"
        nil
      end
    end

    def self.get_player_data(account_id)
      data = nil
      stalker = HiveStalker::Stalker.new

      execution_time = Benchmark.realtime do
        begin
          data = stalker.get_player_data(account_id)
        rescue HiveStalker::APIError => e
          puts "Error: Could not retrieve data for account #{ account_id }: #{ e.message }"
        end
      end

      if data
        @query_time.observe({ status: :success}, execution_time)
      else
        @query_time.observe({ status: :error}, execution_time)
      end

      data
    end

    def self.steamid_help_message(event)
      if @rate_limiter.rate_limited?(:hive_help_message, event.author)
        ''
      else
        "\n\nIf you do not know your Steam ID, you can use a tool like https://steamid.io to find it."
      end
    end


    def self.rate_limited?(event)
      if global_rate_limited?
        puts 'Hit global rate limit, throttling...'
        true
      elsif per_user_rate_limited?(event.author)
        puts "Hit rate limit for #{ event.author.username }, throttling..."
        event.author.pm Config::HiveInterface::PER_USER_RATE_LIMIT_MESSAGE
        true
      else
        false
      end
    end

    def self.global_rate_limited?
      @rate_limiter.rate_limited?(
        :hive_global_api_calls,
        :get_player_data
      )
    end

    def self.per_user_rate_limited?(user)
      @rate_limiter.rate_limited?(
        :hive_per_user_api_calls,
        user
      )
    end
  end
end
