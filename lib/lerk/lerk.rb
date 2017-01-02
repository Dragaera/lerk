# coding: utf-8

require 'discordrb'

module Lerk
  class Lerk
    def initialize(client_id:, token:, prefix: '!')
      @client_id = client_id
      @token     = token
      @prefix    = prefix

      @bot = Discordrb::Commands::CommandBot.new(token: @token, client_id: @client_id, prefix: @prefix)

      bind_commands
    end

    def invite_url
      @bot.invite_url
    end

    def run
      @bot.run
    end

    private
    def bind_commands
      @bot.command :hive2 do |event, steam_id|
        cmd_hive2(event, steam_id)
      end
    end

    def cmd_hive2(event, steam_id)
      if steam_id.nil?
        "Usage: #{ @prefix }hive2 <Steam ID>"
      else
        "Querying Hive 2 for your data, #{ steam_id }"
      end
    end
  end
end
