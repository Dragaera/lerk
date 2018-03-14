# coding: utf-8

module Lerk
  module Internal
    SERVER_FORMAT_STRING = "Server count: %d\n%s"
    SERVER_ENTRY_FORMAT_STRING = '- %s (Owner: %s/%s, Member count: %d)'

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

      @cmd_servers_counter = Prometheus::Wrapper.default.counter(
        :lerk_commands_servers_total,
        'Number of issued `!servers` commands.'
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

      @bot.command(
        :servers,
        description: 'Shows servers the bot is in',
        usage: '!servers',
        min_args: 0,
        max_args: 0,
        permission_level: Lerk::PERMISSION_LEVEL_ADMIN,
      ) do  |event|
        command_servers(event)
      end
    end

    def self.command_version(event)
      Logger.command(event, 'version')
      @cmd_version_counter.increment({ status: :success }, event: event)
      "Version: #{ ::Lerk::VERSION }\nChangelog: https://github.com/Dragaera/lerk/blob/master/CHANGELOG.md"
    end

    def self.command_servers(event)
      Logger.command(event, 'servers')

      unless @bot.connected?
        @cmd_servers_counter.increment({ status: :not_connected }, event: event)
        event.respond 'Not connected to any servers'
        return nil
      end

      servers = @bot.servers
      server_entries = servers.map do |_, server|
        SERVER_ENTRY_FORMAT_STRING % [
          server.name,
          server.owner.username,
          server.owner.id,
          server.members.length
        ]
      end

      msg = SERVER_FORMAT_STRING % [servers.length, server_entries.join("\n")]
      @cmd_servers_counter.increment({ status: :success }, event: event)

      msg
    end
  end
end
