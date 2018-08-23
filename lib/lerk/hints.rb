require 'lerk/hints/local_file_source'
require 'lerk/hints/http_download_source'

require 'lerk/hints/parser'

require 'lerk/hints/json_exporter'
require 'lerk/hints/sequel_exporter'

module Lerk
  module Hints
    EVENT_KEY_HINTS = 'cmd_hints_total'

    def self.register(bot)
      @bot = bot
      @logger = ::Lerk.logger

      init_events
      init_metrics
      bind_commands
    end

    private
    def self.init_events
      @event_hints_total = Event.register(
        key: EVENT_KEY_HINTS,
        show_in_stats_output: true,
        stats_output_description: '**I need help** (`!hint` uses)',
        stats_output_order: 5,
      )
    end

    def self.init_metrics
      @cmd_counter = Prometheus::Wrapper.default.counter(
        :lerk_commands_hint_total,
        'Number of issued `!hint` commands.'
      )
    end

    def self.bind_commands
      @bot.command(
        [:hint, :tip],
        description: 'Get a tip on how to play NS2',
        usage: '!hint [--basic|--advanced|--veteran] [tag]',
        min_args: 0,
        max_args: 2,
      ) do |event, arg1, arg2|
        if arg1 && arg1.start_with?('--')
          command_hint(event, group: arg1, tag: arg2)
        else
          command_hint(event, tag: arg1)
        end
      end
    end

    def self.command_hint(event, group: nil, tag: nil)
      discord_user = Util.discord_user_from_database(event)

      @logger.command(event, 'hint', { group: group, tag: tag })

      @cmd_counter.increment({ status: :success }, event: event)
      @event_hints_total.count(discord_user)

      group = group.gsub(/^--/, '').to_sym if group

      hint = Hint.find(group: group, tag: tag).to_a.sample
      if Config::Hints::SNARKY_COMMENT_CHANCE > 0 && rand(Config::Hints::SNARKY_COMMENT_CHANCE) == 0
        'Just git gud!'
      else
        hint.text
      end

    rescue ArgumentError => e
      e.message
    end
  end
end
