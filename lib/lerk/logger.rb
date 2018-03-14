# coding: utf-8

module Lerk
  module Logger
    def self.log(msg)
      puts "#{ timestamp } #{ msg }"
    end

    def self.command(event, cmd, args = {})
      issuer = event.author.username
      source = if event.channel.pm?
                 '(Direct Message)'
               else
                 "#{ event.server.name }/#{ event.channel.name }"
               end

      arg_string = args.map { |k, v| "#{ k } = #{ v }" }.join(', ')

      puts "#{ timestamp } [#{ issuer } @ #{ source }]: #{ cmd }(#{ arg_string })"
    end

    private
    def self.timestamp
      Time.now.strftime('%FT%T%:z')
    end
  end
end
