# coding: utf-8
require 'json'

module Lerk
  module Excuse
    EXCUSES_FILE = 'data/excuses.json'
    # Based on http://pages.cs.wisc.edu/~ballard/bofh/excuses

    def self.register(bot, registry: registry)
      @bot = bot
      @registry = registry
      @excuses = JSON.load(IO.read(EXCUSES_FILE))['excuses']

      init_rate_limiter
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

    def self.init_metrics
      @cmd_counter = @registry.counter(
        :lerk_commands_excuse_total,
        'Number of issued `!excuse` commands.'
      )
      @excuse_counter = @registry.counter(
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
      amount ||= 1
      amount = amount.to_i

      Logger.command(event, 'excuse', { amount: amount })

      if amount < 1
        @cmd_counter.increment({ status: :less_than_one })
        return "No excuse needed? Congratulations!"
      elsif amount > Config::Excuse::MAXIMUM_AMOUNT
        @cmd_counter.increment({ status: :exceeded_threshold })
        return "You can't possibly need more than #{ Config::Excuse::MAXIMUM_AMOUNT } excuses!"
      end

      if rate_limited?(event, amount)
        @cmd_counter.increment({ status: :rate_limited })
        return "That's too many excuses!"
      end

      @cmd_counter.increment({ status: :success })
      @excuse_counter.increment({}, amount)
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
