# coding: utf-8

module Lerk
  module Prometheus
    class DiscordCounter < ::Prometheus::Client::Counter
      include ::Lerk::Prometheus::Util

      def increment(labels = {}, by = 1, event:)
        source = message_source(event)
        labels[:discord_server] = source[:server]
        labels[:discord_channel] = source[:channel]

        super(labels, by)
      end
    end
  end
end
