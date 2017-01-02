# coding: utf-8

require 'discordrb'
require 'steam_id'
require 'hive_stalker'

module Lerk
  class Lerk
    SECONDS_PER_MINUTE = 60
    SECONDS_PER_HOUR = SECONDS_PER_MINUTE * 60
    SECONDS_PER_DAY = SECONDS_PER_HOUR * 24

    def initialize(client_id:, token:, steam_web_api_key:, prefix: '!')
      @client_id         = client_id
      @token             = token
      @steam_web_api_key = steam_web_api_key
      @prefix            = prefix

      @bot = Discordrb::Commands::CommandBot.new(token: @token, client_id: @client_id, prefix: @prefix)

      create_rate_limiters
      bind_commands
    end

    def invite_url
      @bot.invite_url
    end

    def run
      @bot.run
    end

    private
    def bind_commands
      @bot.command :hive2 do |event, steam_id|
        # Per-use rate limit
         if @rate_limiter.rate_limited?(:hive2_user_api_calls, event.author)
           puts "Hit rate limit for #{ event.author.username }, throttling..."
           msg = <<EOF
Hello there!

You have reached the rate limit of Hive 2 queries.
Please wait a few seconds before you issue another query. :)
EOF
           event.author.pm msg
           next
         end

        # Global rate limit
        if @rate_limiter.rate_limited?(:hive2_global_api_calls, :hive_get_player_data)
          puts 'Hit global rate limit, throttling...'
          next
        end

        cmd_hive2(event, steam_id)
      end

      @bot.command :hi do |event|
        event.author.pm 'Hai'
      end
    end

    def create_rate_limiters
      @rate_limiter = Discordrb::Commands::SimpleRateLimiter.new
      # Global rate limit.
      @rate_limiter.bucket(
        :hive2_global_api_calls,
        limit:     Config::HIVE2_GLOBAL_RATE_LIMIT,
        time_span: Config::HIVE2_GLOBAL_RATE_TIME_SPAN
      )

      @rate_limiter.bucket(
        :hive2_user_api_calls,
        limit:     Config::HIVE2_USER_RATE_LIMIT,
        time_span: Config::HIVE2_USER_RATE_TIME_SPAN
      )
    end

    def cmd_hive2(event, steam_id)
      if steam_id.nil?
        return "Usage: #{ @prefix }hive2 <Steam ID>"
      end

      account_id = resolve_account_id(steam_id)
      if account_id.nil?
        return "Could not convert #{ steam_id } to account ID, please try another."
      end

      data = get_player_data(account_id)
      if data.nil?
        return "Could not retrieve your data."
      end

      sprintf(
        'Skill: %s, Level: %s, Score: %s, Playtime: %s',
        data.skill,
        data.level,
        data.score,
        pp_timespan(data.time_total)
      )
    end

    def resolve_account_id(s)
      begin
        SteamID::SteamID.from_string(s, steam_api_key: @steam_web_api_key)
      rescue WebApiError, ArgumentError => e
        puts "Error: Could not convert #{ s } to account ID: #{ e.message }"
        nil
      end
    end

    def get_player_data(account_id)
      stalker = HiveStalker::Stalker.new
      begin
        stalker.get_player_data(account_id)
      rescue HiveStalker::APIError => e
        puts "Error: Could not retrieve data for account #{ account_id }: #{ e.message }"
        nil
      end
    end

    def pp_timespan(seconds)
      if seconds >= SECONDS_PER_DAY
        days = seconds / SECONDS_PER_DAY
        seconds -= days * SECONDS_PER_DAY
      else
        days = 0
      end

      if seconds >= SECONDS_PER_HOUR
        hours = seconds / SECONDS_PER_HOUR
        seconds -= hours * SECONDS_PER_HOUR
      else
        hours = 0
      end

      if seconds >= SECONDS_PER_MINUTE
        minutes = seconds / SECONDS_PER_MINUTE
        seconds -= minutes * SECONDS_PER_MINUTE
      else
        minutes = 0
      end

      out = []
      out << "#{ days }d" if days > 0
      out << "#{ hours }h" if hours > 0
      out << "#{ minutes }m" if minutes > 0
      out << "#{ seconds }s" if seconds > 0 || (seconds == 0 && minutes == 0 && hours == 0 && days == 0)

      out.join(' ')
    end
  end
end
