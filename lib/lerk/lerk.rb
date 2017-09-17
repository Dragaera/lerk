# coding: utf-8

require 'discordrb'
require 'steam_id'
require 'hive_stalker'
require 'silverball'

require_relative 'internal'
require_relative 'hive_interface'
require_relative 'excuse'

module Lerk
  class Lerk
    extend Silverball::DateTime
    extend Silverball::Numbers

    def initialize(client_id:, token:, prefix: '!')
      @client_id         = client_id
      @token             = token
      @prefix            = prefix

      @bot = Discordrb::Commands::CommandBot.new(
        token:        @token,
        client_id:    @client_id,
        prefix:       @prefix,
        help_command: :help,
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
  end
end
