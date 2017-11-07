# coding: utf-8

module Lerk
  module Prometheus
    class DiscordHistogram < ::Prometheus::Client::Histogram
      include ::Lerk::Prometheus::Util

      def observe(labels = {}, value = 1, event:)
        source = message_source(event)
        labels[:discord_server] = source[:server]
        labels[:discord_channel] = source[:channel]

        super(labels, value)
      end
    end
  end
end
