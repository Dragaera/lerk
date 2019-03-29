# coding: utf-8

module Lerk
  module Internal
    SERVER_FORMAT_STRING = "Server count: %d\n%s"
    SERVER_ENTRY_FORMAT_STRING = '- %s/%s (Owner: %s/%s, Member count: %d) <%s>'

    def self.register(bot)
      @bot = bot
      @logger = ::Lerk.logger

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
        return if Util.ignored?(event)
        command_version(event)
      end

      @bot.command(
        :servers,
        description: 'Shows servers the bot is in',
        usage: '!servers [create_invites = false]',
        min_args: 0,
        max_args: 1,
        permission_level: Lerk::PERMISSION_LEVEL_ADMIN,
      ) do  |event, create_invites|
        return if Util.ignored?(event)
        command_servers(event, create_invites: create_invites == 'true')
      end

      @bot.command(
        :ignore,
        description: 'Ignores a user',
        usage: '!ignore <discord_id>',
        min_args: 1,
        max_args: 1,
        permission_level: Lerk::PERMISSION_LEVEL_ADMIN,
      ) do |event, id|
        return if Util.ignored?(event)
        command_ignore(event, id)
      end

      @bot.command(
        :ignores,
        description: 'Lists ignores',
        usage: '!ignores',
        min_args: 0,
        max_args: 0,
        permission_level: Lerk::PERMISSION_LEVEL_ADMIN,
      ) do |event|
        return if Util.ignored?(event)
        command_ignores(event)
      end

      @bot.command(
        :unignore,
        description: 'Unignores a user',
        usage: '!unignore <discord_id>',
        min_args: 1,
        max_args: 1,
        permission_level: Lerk::PERMISSION_LEVEL_ADMIN,
      ) do |event, id|
        # Not ignoring people here on purpose - don't want to lock ourselves out. ;)
        command_unignore(event, id)
      end

      @bot.command(
        :leave,
        description: 'Leaves a guild',
        usage: '!leave <guild_id>',
        min_args: 1,
        max_args: 1,
        permission_level: Lerk::PERMISSION_LEVEL_ADMIN,
      ) do |event, id|
        return if Util.ignored?(event)
        command_leave(event, id)
      end

      @bot.command(
        :invite,
        description: 'Attempt to generate an invite to a guild',
        usage: '!invite <guild_id>',
        min_args: 1,
        max_args: 1,
        permission_level: Lerk::PERMISSION_LEVEL_ADMIN,
      ) do |event, id|
        return if Util.ignored?(event)
        command_invite(event, id)
      end
    end

    def self.command_version(event)
      @logger.command(event, 'version')
      @cmd_version_counter.increment({ status: :success }, event: event)
      "Version: #{ ::Lerk::VERSION }\nChangelog: https://github.com/Dragaera/lerk/blob/master/CHANGELOG.md"
    end

    def self.command_servers(event, create_invites: false)
      @logger.command(event, 'servers')

      unless @bot.connected?
        @cmd_servers_counter.increment({ status: :not_connected }, event: event)
        event.respond 'Not connected to any servers'
        return nil
      end

      servers = @bot.servers
      server_entries = servers.map do |_, server|
        SERVER_ENTRY_FORMAT_STRING % [
          server.name,
          server.id,
          server.owner.username,
          server.owner.id,
          server.member_count,
          create_invites ? create_invite(server) : ''
        ]
      end

      msg = SERVER_FORMAT_STRING % [servers.length, server_entries.join("\n")]
      @cmd_servers_counter.increment({ status: :success }, event: event)

      msg
    end

    def self.command_ignore(event, id)
      @logger.command(event, 'ignore', discord_id: id)

      user = DiscordUser.first(discord_id: id)
      if user
        user.ignore
        "User '#{ user.last_nick }' added to ignore list."
      else
        "I don't know this user."
      end
    end

    def self.command_unignore(event, id)
      @logger.command(event, 'unignore', discord_id: id)

      user = DiscordUser.first(discord_id: id)
      if user
        user.unignore
        "User '#{ user.last_nick }' removed from ignore list."
      else
        "I don't know this user."
      end
    end

    def self.command_ignores(event)
      @logger.command(event, 'ignores')

      out = ['Ignores:']
      out += DiscordUser.
        where(ignored: true).
        map { |user| "- #{ user.discord_id } (#{ user.last_nick })"}

      out.join("\n")
    end

    def self.command_leave(event, id)
      begin
        guild_id = Integer(id)
      rescue ArgumentError
        event << 'Guild ID must be numeric'
        return
      end

      server = @bot.servers[guild_id]

      unless server
        event << 'No such server'
        return
      end

      server.leave
    end

    def self.command_invite(event, id)
      begin
        guild_id = Integer(id)
      rescue ArgumentError
        event << 'Guild ID must be numeric'
        return
      end

      server = @bot.servers[guild_id]

      unless server
        event << 'No such server'
        return
      end

      event << "Invite: #{ create_invite(server) }"
    end

    def self.create_invite(server)
      channel = server.channels.first
      invite  = channel.make_invite

      invite.url
    rescue Discordrb::Errors::NoPermission
      'Unable to create invite'
    end
  end
end
