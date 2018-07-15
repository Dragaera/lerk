# coding: utf-8

module Lerk
  class Logger
    def initialize(*args, level: :debug)
      @logger = ::Logger.new(STDOUT)
      @logger.level = level
    end

    def log(msg)
      info(msg)
    end

    def command(event, cmd, args = {})
      issuer = event.author.username
      source = if event.channel.pm?
                 '(Direct Message)'
               else
                 "#{ event.server.name }/#{ event.channel.name }"
               end

      arg_string = args.map { |k, v| "#{ k } = #{ v }" }.join(', ')

      info "[#{ issuer } @ #{ source }]: #{ cmd }(#{ arg_string })"
    end

    def debug(msg)
      @logger.debug(msg)
    end

    def info(msg)
      @logger.info(msg)
    end

    def warn(msg)
      @logger.warn(msg)
    end

    def error(msg)
      @logger.error(msg)
    end

    def fatal(msg)
      @logger.fatal(msg)
    end

    def unknown(msg)
      @logger.unknown(msg)
    end

    private
    def timestamp
      Time.now.strftime('%FT%T%:z')
    end
  end

  def self.logger
    Logger.new
  end
end
