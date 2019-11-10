# coding: utf-8

module Lerk
  module UserAccounts
    KNOWN_ACCOUNT_TYPES = %w(steam)

    def self.register(bot)
      @bot = bot
      @logger = ::Lerk.logger

      init_metrics
      bind_commands
    end

    private
    def self.init_metrics
      @cmd_link_counter = Prometheus::Wrapper.default.counter(
        :lerk_commands_link_total,
        'Number of issued `!link` commands.'
      )

      @cmd_unlink_counter = Prometheus::Wrapper.default.counter(
        :lerk_commands_unlink_total,
        'Number of issued `!unlink` commands.'
      )
    end

    def self.bind_commands
      @bot.command(
        :link,
        description: 'Tell the bot about your other (eg Steam) accounts',
        usage: '!link [--steam steam_id]',
        min_args: 0,
        max_args: 2,
      ) do  |event, *args|
        return if Util.ignored?(event)

        if args.length == 0
          command_link_connections(event)
        elsif args.length == 2
          type, arg = args
          command_link_manual(event, type, arg)
        else
          return 'Invalid usage. Check `!help link`'
        end
      end

      @bot.command(
        :unlink,
        description: 'Make the bot forget about your other accounts',
        usage: '!unlink (--steam)',
        min_args: 1,
        max_args: 1,
      ) do  |event, type|
        return if Util.ignored?(event)
        command_unlink(event, type)
      end
    end

    def self.command_link_manual(event, type, arg)
      @logger.command(event, 'link', { target: 'manual', type: type, arg: arg })

      account_type = account_type(type)
      unless account_type
        @cmd_link_counter.increment({ status: :unknown_account_type }, event: event)
        return "Unknown account type: #{ type }. Check `!help link`"
      end

      user = Util.discord_user_from_database(event)
      if account_type == 'steam'
        account_id = Util.resolve_steam_account_id(arg)
        unless account_id
          @cmd_link_counter.increment({ status: :invalid_steam_id }, event: event)
          return "Unknown Steam ID: #{ arg }"
        end

        user.update(steam_account_id: account_id, steam_account_verified: false)
        @cmd_link_counter.increment({ status: :success }, event: event)
        return "Linked Steam account #{ account_id } to Discord user #{ user.discord_id }."
      end
    end

    def self.command_link_connections(event)
      @logger.command(event, 'link', { target: 'connections' })

      user = Util.discord_user_from_database(event)
      url = user.oauth_auth_url
      dm_msg = "Please click on the following link to allow me to learn of your linked accounts:\n#{ url }"
      event.user.pm(dm_msg)

      return "#{ event.user.mention }: You have been sent a direct message with a link.\nClick on it to allow me to learn of your linked accounts."

    rescue Discordrb::Errors::NoPermission => e
      return "I was unable to send you a direct message, please adjust your settings to allow receiving DMs:\nRight click the server icon -> Privacy Settings -> Allow direct messages from server members"
    end

    def self.command_unlink(event, type)
      @logger.command(event, 'unlink', { type: type })

      account_type = account_type(type)
      unless account_type
        @cmd_unlink_counter.increment({ status: :unknown_account_type }, event: event)
        return "Unknown account type: #{ type }. Check `!help unlink`"
      end

      user = Util.discord_user_from_database(event)
      if account_type == 'steam'
        @cmd_unlink_counter.increment({ status: :success }, event: event)
        user.update(steam_account_id: nil, steam_account_verified: false)
        return "Unlinked Steam account from Discord user #{ user.discord_id }."
      end
    end

    def self.account_type(type)
      account_type = type.gsub(/^\-\-/, '')
      if KNOWN_ACCOUNT_TYPES.include? account_type
        account_type
      else
        nil
      end
    end
  end
end
