# coding: utf-8

module Lerk
  module Statistics
    EVENT_KEY_STATS = 'cmd_stats_total'

    def self.register(bot)
      @bot = bot

      init_metrics
      init_events
      bind_commands
    end

    private
    def self.init_events
      @event_stats_total = Event.register(
        key: EVENT_KEY_STATS,
        show_in_stats_output: true,
        stats_output_description: '**Meta!** (`!stats` uses)',
        stats_output_order: 21,
      )
    end

    def self.init_metrics
      @cmd_counter = Prometheus::Wrapper.default.counter(
        :lerk_commands_stats_total,
        'Number of issued `!stats` commands.'
      )
    end

    def self.bind_commands
      @bot.command(
        [:stats],
        description: 'Retrieve command usage statistics',
        usage: '!stats',
        min_args: 0,
        max_args: 0,
      ) do |event|
        command_stats(event)
      end
    end

    def self.command_stats(event)
      discord_user = Util.discord_user_from_database(event)

      Logger.command(event, 'stats')

      @cmd_counter.increment({ status: :success }, event: event)
      @event_stats_total.count(discord_user)

      out = ['You want stats? Have some stats!', '']
      Event
        .where(show_in_stats_output: true)
        .order(Sequel.asc(:stats_output_order))
        .each do |event|
        out << event.stats_output_description
        top_n_counters = event.event_counters_dataset.order_by(Sequel.desc(:count)).first(5)
        out += top_n_counters.map do |counter|
          "- #{ counter.discord_user.last_nick }: #{ counter.count }"
        end
        out << ''
      end

      out.join("\n")
    end
  end
end
