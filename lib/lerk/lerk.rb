# coding: utf-8

require 'discordrb'
require 'steam_id'
require 'hive_stalker'
require 'silverball'

module Lerk
  class Lerk
    extend Silverball::DateTime
    extend Silverball::Numbers

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
      @bot.command [:hive2, :hive] do |event, steam_id|
        # Per-user rate limit
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

      'Skill: %{skill}, Level: %{level}, Score: %{score}, Playtime: %{playtime} (%{playtime_in_hours})' % {
        skill:             self.class.number_with_separator(data.skill),
        level:             data.level,
        score:             self.class.number_with_separator(data.score),
        playtime:          self.class.timespan_in_words(data.time_total),
        playtime_in_hours: self.class.timespan_in_words(data.time_total, unit: :hours, round: 1),
      }
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
  end
end
