# coding: utf-8

require 'discordrb'
require 'steam_id'
require 'prometheus'

require 'hive_stalker'
require 'silverball'

require_relative 'logger'

require_relative 'internal'
require_relative 'hive_interface'
require_relative 'excuse'

module Lerk
  class Lerk
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

      Internal.register(@bot)
      HiveInterface.register(@bot)
      Excuse.register(@bot)
    end

    def invite_url
      @bot.invite_url
    end

    def run
      @bot.run
    end

    def handle_exception(event, exception)
      excuse = Excuse.get_excuses.first
      out = "Oops, omething went wrong:\n#{ excuse }"
      event.respond(out)
    end
  end
end
