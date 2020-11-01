# coding: utf-8
require 'benchmark'

require 'silverball'
require 'gorgerb'

module Lerk
  module HiveInterface
    extend Silverball::DateTime
    extend Silverball::Numbers

    GORGE_MESSAGE_TEMPLATE = <<EOF
**K/D (%{sample_size} rounds)**: **Alien**: %{kd_alien}, **Marine**: %{kd_marine}
**Acc (%{sample_size} rounds)**: **Alien**: %{accuracy_alien}%%, **Marine (no Onos)**: %{accuracy_marine}%%
EOF

    EMBED_MESSAGE_TEMPLATE = <<EOF
**Skill**:
  - **Alien** (Field / Comm): %{skill_alien_field} / %{skill_alien_comm}
  - **Marine** (Field / Comm): %{skill_marine_field} / %{skill_marine_comm}
%{gorge_statistics}
**Time**: **Total**: %{time_total}, **Alien**: %{time_alien}, **Marine**: %{time_marine}
EOF

    DEBUG_MESSAGE_TEMPLATE = <<EOF
```
Alias: %{alias}
Player ID: %{player_id}
Steam ID: %{steam_id}

Badges: %{badges}
Reinforced tier: %{reinforced_tier}

Field:
  Skill: %{skill_field}
  Offset: %{offset_field}
  Adagrad: %{adagrad_field}

Commander:
  Skill: %{skill_commander}
  Offset: %{offset_commander}
  Adagrad: %{adagrad_commander}

Time:
  Alien: %{time_alien}
  Marine: %{time_marine}
  Commander: %{time_commander}
  Total: %{time_total}

Experience: %{experience}
Level: %{level}
Score: %{score}
```
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
        usage: '!hive [--debug] [Steam ID | Default: Linked account or Discord username]',
        min_args: 0,
        max_args: 2,
      ) do |event, arg1, arg2|
        return if Util.ignored?(event)
        command_hive(event, arg1, arg2)
      end
    end

    def self.command_hive(event, arg1, arg2)
      if arg1 == '--debug'
        steam_id = arg2
        debug = true
      else
        steam_id = arg1
        debug = false
      end

      discord_user = Util.discord_user_from_database(event)
      steam_id = Util.sanitize_discord_input(steam_id)

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

      gorge_data = gorge_query(account_id)
      gorge_statistics = format_gorge_data(
        gorge_data
      )

      if debug
        args = {
          alias: data.alias,
          player_id: data.player_id,
          steam_id: data.steam_id,

          badges: data.badges.inspect,
          reinforced_tier: data.reinforced_tier,

          skill_field: data.skill,
          offset_field: data.skill_offset,
          adagrad_field: data.adagrad_sum,

          skill_commander: data.commander_skill,
          offset_commander: data.commander_skill_offset,
          adagrad_commander: data.commander_adagrad_sum,

          time_alien: data.time_alien,
          time_marine: data.time_marine,
          time_commander: data.time_commander,
          time_total: data.time_total,

          experience: data.experience,
          level: data.level,
          score: data.score,
        }
        return DEBUG_MESSAGE_TEMPLATE % args
      end

      skills = data.specific_skills
      args = {
        alias:              data.alias,
        profile_url:        observatory_url(account_id),
        skill_alien_field:  self.number_with_separator(skills.alien.field),
        skill_alien_comm:   self.number_with_separator(skills.alien.commander),
        skill_marine_field: self.number_with_separator(skills.marine.field),
        skill_marine_comm:  self.number_with_separator(skills.marine.commander),
        time_total:         self.timespan_in_words(data.time_total,  unit: :hours, round: 1),
        time_alien:         self.timespan_in_words(data.time_alien,  unit: :hours, round: 1),
        time_marine:        self.timespan_in_words(data.time_marine, unit: :hours, round: 1),
        gorge_statistics:   gorge_statistics.chomp,
      }

      event.channel.send_embed do |embed|
        embed.title = args[:alias]
        embed.url   = args[:profile_url]
        embed.description = EMBED_MESSAGE_TEMPLATE % args
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

      client.player_statistics(
        steam_id,
        statistics_classes: [Config::Gorge::STATISTICS_CLASS]
      )
    rescue Gorgerb::Error => e
      nil
    end

    def self.format_gorge_data(gorge_data)
      if gorge_data
        args = {}

        data = gorge_data.send(Config::Gorge::STATISTICS_CLASS)

        args[:sample_size] = data.meta.sample_size

        args[:kd_alien] = if data.kdr.alien
                            data.kdr.alien.round(2)
                          else
                            'N/A'
                          end

        args[:kd_marine] = if data.kdr.marine
                             data.kdr.marine.round(2)
                           else
                             'N/A'
                           end

        args[:accuracy_alien] = if data.accuracy.alien
                                  (100 * data.accuracy.alien).round(1)
                                else
                                  'N/A'
                                end

        args[:accuracy_marine] = if data.accuracy.marine.no_onos
                                   (100 * data.accuracy.marine.no_onos).round(1)
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
