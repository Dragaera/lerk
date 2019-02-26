module Lerk
  module Interblag
    FIRST_PART = [
      'World Wide',
      'Inter-',
      'Blogo-',
      'Blago-',
      'Web-',
    ]
    SECOND_PART = [
      'Net',
      'Web',
      'Sphere',
      'Tubes',
      'Blag',
    ]

    def self.register(bot)
      @bot = bot
      @logger = ::Lerk.logger

      init_metrics
      bind_commands
    end

    private
    def self.init_metrics
      @cmd_interblag_counter = Prometheus::Wrapper.default.counter(
        :lerk_commands_interblag_total,
        'Number of issued `!interblag` commands.'
      )
    end

    def self.bind_commands
      @bot.command(
        :interblag,
        description: 'I heard about it on the ...',
        usage: '!interblag',
        min_args: 0,
        max_args: 0,
      ) do  |event|
        return if Util.ignored?(event)
        command_interblag(event)
      end
    end

    def self.command_interblag(event)
      @logger.command(event, 'interblag')
      @cmd_interblag_counter.increment({ status: :success }, event: event)

      first  = FIRST_PART.sample.dup
      second = SECOND_PART.sample.dup

      out = ''
      if first.end_with? '-'
        out << first.chop << second.downcase
      else
        out << first << ' ' << second
      end

      "I heard about it on the #{ out }!"
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

    def self.create_invite(server)
      channel = server.channels.first
      invite  = channel.make_invite

      invite.url
    rescue Discordrb::Errors::NoPermission
      'Unable to create invite'
    end
  end
end
