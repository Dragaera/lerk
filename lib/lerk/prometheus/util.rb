# coding: utf-8

module Lerk
  module Prometheus
    module Util
      def message_source(event)
        server = event.channel.pm?  ? 'Direct Message' : event.server.name
        channel = event.channel.pm? ? 'Direct Message' : event.channel.name

        {
          server: server,
          channel: channel
        }
      end
    end
  end
end
