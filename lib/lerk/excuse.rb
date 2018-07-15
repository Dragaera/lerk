# coding: utf-8
require 'json'

module Lerk
  module Excuse
    # Based on http://pages.cs.wisc.edu/~ballard/bofh/excuses
    EXCUSES_FILE = 'data/excuses.json'

    EVENT_KEY_EXCUSE_TOTAL = 'cmd_excuse_total'

    def self.register(bot)
      @bot = bot
      @logger = ::Lerk.logger
      @excuses = JSON.load(IO.read(EXCUSES_FILE))['excuses']

      init_rate_limiter
      init_events
      init_metrics
      bind_commands
    end

    private
    def self.init_rate_limiter
      @rate_limiter = Discordrb::Commands::SimpleRateLimiter.new

      @rate_limiter.bucket(
        :excuse_per_user_calls,
        limit:     Config::Excuse::PER_USER_RATE_LIMIT,
        time_span: Config::Excuse::PER_USER_RATE_TIME_SPAN
      )
    end

    def self.init_events
      @event_excuse = Event.register(
        key: EVENT_KEY_EXCUSE_TOTAL,
        show_in_stats_output: true,
        stats_output_description: '**Honest souls** (Requested excuses)',
        stats_output_order: 11,
      )
    end

    def self.init_metrics
      @cmd_counter = Prometheus::Wrapper.default.counter(
        :lerk_commands_excuse_total,
        'Number of issued `!excuse` commands.'
      )
      @excuse_counter = Prometheus::Wrapper.default.counter(
        :lerk_excuses_total,
        'Number of generated excuses.'
      )
    end

    def self.bind_commands
      @bot.command(
        :excuse,
        description: 'Generates a rock-solid excuse for anything',
        usage: '!excuse <amount = 1>',
        min_args: 0,
        max_args: 1,
      ) do |event, amount|
        command_excuse(event, amount)
      end
    end

    def self.command_excuse(event, amount)
      discord_user = Util.discord_user_from_database(event)

      amount ||= 1
      amount = amount.to_i

      @logger.command(event, 'excuse', { amount: amount })

      if amount < 1
        @cmd_counter.increment({ status: :less_than_one }, event: event)
        return "No excuse needed? Congratulations!"
      elsif amount > Config::Excuse::MAXIMUM_AMOUNT
        @cmd_counter.increment({ status: :exceeded_threshold }, event: event)
        return "You can't possibly need more than #{ Config::Excuse::MAXIMUM_AMOUNT } excuses!"
      end

      if rate_limited?(event, amount)
        @cmd_counter.increment({ status: :rate_limited }, event: event)
        return "That's too many excuses!"
      end

      @cmd_counter.increment({ status: :success }, event: event)
      @event_excuse.count(discord_user, count: amount)
      @excuse_counter.increment({}, amount, event: event)
      if amount == 1
        get_excuses(amount: 1).first
      else
        "Your excuses:\n#{ get_excuses(amount: amount).map { |ex| "- #{ ex }" }.join("\n") }"
      end
    end

    def self.get_excuses(amount: 1)
      @excuses.sample(amount)
    end

    def self.rate_limited?(event, amount)
      @rate_limiter.rate_limited?(
        :excuse_per_user_calls,
        event.author,
        increment: amount
      )
    end
  end
end
