# coding: utf-8
require 'benchmark'

require 'silverball'
require 'gorgerb'

module Lerk
  module HiveInterface
    extend Silverball::DateTime
    extend Silverball::Numbers

    GORGE_MESSAGE_TEMPLATE = <<EOF
**K/D**: **Alien**: %{kd_alien}, **Marine**: %{kd_marine}
**Acc**: **Alien**: %{accuracy_alien}%%, **Marine (no Onos)**: %{accuracy_marine}%%
EOF

    PLAINTEXT_MESSAGE_TEMPLATE = <<EOF
**%{alias}** (%{profile_url})
**Skill**: %{skill}, **Level**: %{level}, **Score**: %{score}
%{gorge_statistics}
**Time**: **Total**: %{time_total}, **Alien**: %{time_alien}, **Marine**: %{time_marine}
EOF
    EMBED_MESSAGE_TEMPLATE = <<EOF
**Skill**: %{skill}
%{gorge_statistics}
**Level**: %{level}
**Score**: %{score}
**Time**: **Total**: %{time_total}, **Alien**: %{time_alien}, **Marine**: %{time_marine}
EOF

    EVENT_KEY_HIVE_SUCCESS = 'cmd_hive_success'
    EVENT_KEY_HIVE_FAILURE = 'cmd_hive_failure'

    def self.register(bot)
      @bot = bot
      @logger = ::Lerk.logger

      init_rate_limiter
      init_events
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

    def self.init_events
      @event_hive_success = Event.register(
        key: EVENT_KEY_HIVE_SUCCESS,
        show_in_stats_output: true,
        stats_output_description: '**Stats whores** (`!hive` uses)',
        stats_output_order: 1,
      )

      @event_hive_failure = Event.register(
        key: EVENT_KEY_HIVE_FAILURE,
        show_in_stats_output: true,
        stats_output_description: '**"I forgot my Steam ID"** (failed `!hive` uses)',
        stats_output_order: 2,
      )
    end

    def self.init_metrics
      @cmd_counter = Prometheus::Wrapper.default.counter(
        :lerk_commands_hive_total,
        'Number of issued `!hive` commands.'
      )

      @query_time = Prometheus::Wrapper.default.histogram(
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
        return if Util.ignored?(event)
        command_hive(event, steam_id)
      end
    end

    def self.command_hive(event, steam_id)
      discord_user = Util.discord_user_from_database(event)

      if rate_limited?(event)
        @cmd_counter.increment({ status: :rate_limited }, event: event)
        return
      end

      if discord_user.steam_account_id
        steam_id ||= discord_user.steam_account_id
      else
        steam_id ||= event.author.username
        @logger.command(event, 'hive_query', { identifier: steam_id })
      end

      account_id = Util.resolve_steam_account_id(steam_id)
      if account_id.nil?
        msg = "Could not convert #{ steam_id } to account ID, please try another."
        msg << steamid_help_message(event)
        @cmd_counter.increment({ status: :identifier_invalid }, event: event)
        @event_hive_failure.count(discord_user)
        return msg
      end

      data = get_player_data(account_id, event)
      if data.nil?
        msg = "Could not retrieve data for ID #{ steam_id } (Account: #{ account_id })."
        msg << steamid_help_message(event)
        @cmd_counter.increment({ status: :no_data_retrieved }, event: event)
        @event_hive_failure.count(discord_user)
        return msg
      end

      @cmd_counter.increment({ status: :success }, event: event)
      @event_hive_success.count(discord_user)

      gorge_statistics = format_gorge_data(gorge_query(account_id))

      args = {
        alias:            data.alias,
        profile_url:      observatory_url(account_id),
        skill:            self.number_with_separator(data.skill),
        level:            data.level,
        score:            self.number_with_separator(data.score),
        time_total:       self.timespan_in_words(data.time_total,  unit: :hours, round: 1),
        time_alien:       self.timespan_in_words(data.time_alien,  unit: :hours, round: 1),
        time_marine:      self.timespan_in_words(data.time_marine, unit: :hours, round: 1),
        gorge_statistics: gorge_statistics.chomp,
      }

      if Config::HiveInterface::ENABLE_EMBEDS
        event.channel.send_embed do |embed|
          embed.title = args[:alias]
          embed.url   = args[:profile_url]
          embed.description = EMBED_MESSAGE_TEMPLATE % args
        end
      else
        PLAINTEXT_MESSAGE_TEMPLATE % args
      end
    end

    def self.get_player_data(account_id, event)
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
        @query_time.observe({ status: :success}, execution_time, event: event)
      else
        @query_time.observe({ status: :error}, execution_time, event: event)
      end

      data
    end

    def self.observatory_url(steam_id)
      # Theoretically we should URL-encode, but it's safe-ish since only values
      # which are valid URL parameters will get this far.
      "#{ Config::Observatory::BASE_URL }/player?steam_id=#{ steam_id }"
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

    def self.gorge_query(steam_id)
      return nil unless Config::Gorge::BASE_URL

      opts = {
        connect_timeout: Config::Gorge::CONNECT_TIMEOUT,
        timeout: Config::Gorge::TIMEOUT,
      }

      if Config::Gorge::HTTP_BASIC_USER && Config::Gorge::HTTP_BASIC_PASSWORD
        opts[:user]     = Config::Gorge::HTTP_BASIC_USER
        opts[:password] = Config::Gorge::HTTP_BASIC_PASSWORD
      end

      client = Gorgerb::Client.new(
        Config::Gorge::BASE_URL,
        opts
      )

      client.player_statistics(steam_id)
    rescue Gorgerb::Error => e
      nil
    end

    def self.format_gorge_data(gorge_data)
      if gorge_data
        args = {}

        args[:kd_alien] = if gorge_data.kdr.alien
                            gorge_data.kdr.alien.round(2)
                          else
                            'N/A'
                          end

        args[:kd_marine] = if gorge_data.kdr.marine
                             gorge_data.kdr.marine.round(2)
                           else
                             'N/A'
                           end

        args[:accuracy_alien] = if gorge_data.accuracy.alien
                                  (100 * gorge_data.accuracy.alien).round(1)
                                else
                                  'N/A'
                                end

        args[:accuracy_marine] = if gorge_data.accuracy.marine.no_onos
                                   (100 * gorge_data.accuracy.marine.no_onos).round(1)
                                 else
                                   'N/A'
                                 end

        GORGE_MESSAGE_TEMPLATE % args
      else
        '(No additional data available)'
      end
    end
  end
end
