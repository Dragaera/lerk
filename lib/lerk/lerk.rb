# coding: utf-8

require 'discordrb'
require 'steam_id'
require 'prometheus'

require 'hive_stalker'
require 'silverball'

require_relative 'logger'

module Lerk
  class Lerk
    PERMISSION_LEVEL_HINTS_ADMIN = 2
    PERMISSION_LEVEL_ADMIN = 10

    def initialize(client_id:, token:, prefix: '!')
      @client_id         = client_id
      @token             = token
      @prefix            = prefix

      @bot = Discordrb::Commands::CommandBot.new(
        token:        @token,
        client_id:    @client_id,
        prefix:       @prefix,
        help_command: :help,
        log_mode:     Config::LOG_LEVEL,
        rescue: self.method(:handle_exception)
      )

      register_admin_users

      Internal.register(@bot)
      HiveInterface.register(@bot)
      Excuse.register(@bot)
      Statistics.register(@bot)
      Hints.register(@bot)
    end

    def invite_url
      @bot.invite_url
    end

    def run
      @bot.run
    end

    def servers
      if @bot.connected?
        @bot.servers
      else
        {}
      end
    end

    def handle_exception(event, exception)
      excuse = Excuse.get_excuses.first
      out = "Oops, omething went wrong:\n#{ excuse }"
      event.respond(out)
    end

    private
    def register_admin_users
      Config::Lerk::ADMIN_USERS.each do |id|
        ::Lerk.logger.log("Granting admin access to user #{ id }")
        @bot.set_user_permission(id, Lerk::PERMISSION_LEVEL_ADMIN)
      end

      Config::Lerk::HINTS_ADMIN_USERS.each do |id|
        ::Lerk.logger.log("Granting hints admin access to user #{ id }")
        @bot.set_user_permission(id, Lerk::PERMISSION_LEVEL_HINTS_ADMIN)
      end
    end
  end
end
