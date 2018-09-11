# coding: utf-8
require 'json'

module Lerk
  module CalendarFacts
    # Based on https://xkcd.com/1930/
    CALENDAR_FACTS_FILE = 'data/calendar_facts.json'

    EVENT_KEY_CALENDAR_FACTS_TOTAL = 'cmd_calendar_facts_total'

    def self.register(bot)
      @bot = bot
      @logger = ::Lerk.logger
      @calendar_facts = JSON.load(IO.read(CALENDAR_FACTS_FILE)).freeze

      init_rate_limiter
      init_events
      init_metrics
      bind_commands
    end

    private
    def self.init_rate_limiter
      @rate_limiter = Discordrb::Commands::SimpleRateLimiter.new

      @rate_limiter.bucket(
        :calendar_facts_per_user_calls,
        limit:     Config::CalendarFacts::PER_USER_RATE_LIMIT,
        time_span: Config::CalendarFacts::PER_USER_RATE_TIME_SPAN
      )
    end

    def self.init_events
      @event_calendar_fact = Event.register(
        key: EVENT_KEY_CALENDAR_FACTS_TOTAL,
        show_in_stats_output: true,
        stats_output_description: '**It is known** (Requested calendar facts)',
        stats_output_order: 12,
      )
    end

    def self.init_metrics
      @cmd_counter = Prometheus::Wrapper.default.counter(
        :lerk_commands_calendar_facts_total,
        'Number of issued `!calendarfact` commands.'
      )
    end

    def self.bind_commands
      @bot.command(
        :calendarfact,
        description: 'Spits out a well-known piece of calendar trivia',
        usage: '!calendarfact',
        min_args: 0,
        max_args: 0,
      ) do |event|
        command_calendarfact(event)
      end
    end

    def self.command_calendarfact(event)
      discord_user = Util.discord_user_from_database(event)

      @logger.command(event, 'calendarfact')

      if rate_limited?(event)
        @cmd_counter.increment({ status: :rate_limited }, event: event)
        return "That's enough facts for now."
      end

      @cmd_counter.increment({ status: :success }, event: event)
      @event_calendar_fact.count(discord_user)

      calendar_fact
    end

    def self.construct_fact(item)
      # We'll remove items of the array further down, and don't want to modify
      # whatever's passed into us.
      item = item.dup
      if item.is_a? Array
        type = item.shift
        if type == 'all'
          item.map { |i| construct_fact(i) }.join(' ')
        elsif type == 'any'
          construct_fact(item.sample)
        else
          @logger.error "Unkown calendarfacts type: #{ type }"
          'Sorry, no facts today. Check back tomorrow. :)'
        end
      else
        item
      end
    end

    def self.calendar_fact
      # Cheap hack to prevent spaces in front of punctuation marks, without
      # having to repeat them multiple times in the factoid snippets.
      construct_fact(@calendar_facts).
        gsub(' .', '.').
        gsub(' ,', ',').
        gsub(' ?', '?')
    end

    def self.rate_limited?(event)
      @rate_limiter.rate_limited?(
        :calendar_facts_per_user_calls,
        event.author,
      )
    end
  end
end
