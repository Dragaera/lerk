# coding: utf-8

require 'tempfile'

module Lerk
  module Latex
    def self.register(bot)
      @bot = bot
      @logger = ::Lerk.logger

      init_metrics
      bind_commands
    end

    private
    def self.init_metrics
      @cmd_latex_counter = Prometheus::Wrapper.default.counter(
        :lerk_commands_latex_total,
        'Number of issued `!latex` commands.'
      )
    end

    def self.bind_commands
      @bot.command(
        :latex,
        description: 'Render LaTeX',
        usage: '!latex <latex>',
        min_args: 1,
      ) do  |event, *args|
        return if Util.ignored?(event)
        command_latex(event, args.join(' '))
      end
    end

    def self.command_latex(event, latex)
      @logger.command(event, 'latex', { latex: latex })
      @cmd_latex_counter.increment({ status: :success }, event: event)

      if Config::Emerald::BASE_URL.empty?
        return 'Emerald not enabled'
      end

      if latex.length > Config::Emerald::MAXIMUM_INPUT_LENGTH
        return "Input must be at most #{ Config::Emerald::MAXIMUM_INPUT_LENGTH } characters. Was: #{ latex.length }."
      end

      image = image_path = nil

      image_path = query_emerald(latex)
      image = File.open(image_path, mode: 'rb')

      event.send_file(image)
    rescue RuntimeError => e
      event << e.message
    ensure
      image.close if image
      File.delete(image_path) if image_path
    end

    def self.query_emerald(latex)
      request = Typhoeus::Request.new(
        Config::Emerald::BASE_URL,
        method: :get,
        params: {
          latex: latex,
        }
      )
      request.run

      response = request.response
      if response.success?
        file = Tempfile.new(['latex', '.png'])
        IO.write(file, response.body)

        file
      elsif response.timed_out?
        raise RuntimeError, 'Timeout while querying API'
      else
        raise RuntimeError, "Error while querying API: #{ response.body }"
      end
    end
  end
end
