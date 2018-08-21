require 'lerk/hints/local_file_source'
require 'lerk/hints/http_download_source'

require 'lerk/hints/parser'

require 'lerk/hints/json_exporter'
require 'lerk/hints/sequel_exporter'

module Lerk
  module Hints
    EXISTING_HINT_LEVELS = [:basic, :advanced, :veteran]

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
        usage: '!hint [--basic|--advanced|--veteran] [category]',
        min_args: 0,
        max_args: 2,
      ) do |event, arg1, arg2|
        if arg1 && arg1.start_with?('--')
          command_hint(event, level: arg1, category: arg2)
        else
          command_hint(event, category: arg1)
        end
      end
    end

    def self.command_hint(event, level: nil, category: nil)
      @logger.command(event, 'hint', { level: level, category: category })

      level = sanitize_level(level)
      category = sanitize_category(category)

      if category
        hints = HintTag.first(tag: category).hints_dataset
      else
        hints = Hint.dataset
      end

      if level
        if level == :basic
          hints = hints.where(group_basic: true)
        elsif level == :advanced
          hints = hints.where(group_advanced: true)
        elsif level == :veteran
          hints = hints.where(group_veteran: true)
        end
      end

      hint = hints.to_a.sample
      return hint.pretty_print

    rescue ArgumentError => e
      e.message
    end

    private
    def self.sanitize_level(level)
      return nil unless level

      level = level.gsub(/^--/, '').to_sym
      if EXISTING_HINT_LEVELS.include? level
        level
      else
        raise ArgumentError, "Unknown level: #{ level }"
      end
    end

    def self.sanitize_category(category)
      return nil unless category

      existing_categories = Set.new(HintTag.select_map(:tag))
      if existing_categories.include? category
        category
      else
        raise ArgumentError, "Unknown category: #{ category }"
      end
    end
  end
end
