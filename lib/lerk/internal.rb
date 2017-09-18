# coding: utf-8

module Lerk
  module Internal
    def self.register(bot)
      @bot = bot

      bind_commands
    end

    private
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
      "Version: #{ ::Lerk::VERSION }\nChangelog: https://bitbucket.org/Lavode/lerk/src/master/CHANGELOG.md"
    end
  end
end
