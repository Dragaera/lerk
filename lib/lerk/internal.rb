# coding: utf-8

module Lerk
  module Internal
    def self.register(bot, registry: registry)
      @bot = bot
      @registry = registry

      init_metrics
      bind_commands
    end

    private
    def self.init_metrics
      @cmd_version_counter = @registry.counter(
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
      @cmd_version_counter.increment({ status: :success })
      "Version: #{ ::Lerk::VERSION }\nChangelog: https://github.com/Dragaera/lerk/blob/master/CHANGELOG.md"
    end
  end
end
