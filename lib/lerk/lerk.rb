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
      @registry = Prometheus::Client.registry

      @client_id         = client_id
      @token             = token
      @prefix            = prefix

      @bot = Discordrb::Commands::CommandBot.new(
        token:        @token,
        client_id:    @client_id,
        prefix:       @prefix,
        help_command: :help,
        log_mode:     Config::LOG_LEVEL,
      )

      Internal.register(@bot, registry: @registry)
      HiveInterface.register(@bot, registry: @registry)
      Excuse.register(@bot, registry: @registry)
    end

    def invite_url
      @bot.invite_url
    end

    def run
      @bot.run
    end
  end
end
