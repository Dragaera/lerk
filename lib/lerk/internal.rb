# coding: utf-8

module Lerk
  module Internal
    def self.register(bot)
      @bot = bot

      init_metrics
      bind_commands
    end

    private
    def self.init_metrics
      @cmd_version_counter = Prometheus::Wrapper.default.counter(
        :lerk_commands_version_total,
        'Number of issued `!version` commands.'
      )
    end

    def self.bind_commands
      @bot.command(
        :version,
        description: 'Shows bot version',
        usage: '!version',
        min_args: 0,
        max_args: 0,
      ) do  |event|
        command_version(event)
      end
    end

    def self.command_version(event)
      Logger.command(event, 'version')
      p @cmd_version_counter
      @cmd_version_counter.increment({ status: :success }, event: event)
      "Version: #{ ::Lerk::VERSION }\nChangelog: https://github.com/Dragaera/lerk/blob/master/CHANGELOG.md"
    end
  end
end
