require 'lerk/hints/local_file_source'
require 'lerk/hints/http_download_source'

require 'lerk/hints/parser'

require 'lerk/hints/json_exporter'
require 'lerk/hints/sequel_exporter'

module Lerk
  module Hints
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
    end

    def self.init_events
    end

    def self.init_metrics
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
      @logger.command(event, 'hint', { group: group, tag: tag })

      group = group.gsub(/^--/, '').to_sym if group

      hint = Hint.find(group: group, tag: tag).to_a.sample
      return hint.pretty_print

    rescue ArgumentError => e
      e.message
    end
  end
end
