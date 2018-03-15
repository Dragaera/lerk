# coding: utf-8

module Lerk
  module Worker
    def self.run(lerk)
      self.init_metrics

      while true do
        @server_gauge.set({}, lerk.servers.count)
        sleep(5)
      end
    end

    private
    def self.init_metrics
      @server_gauge = Prometheus::Wrapper.default.gauge(
        :lerk_servers_count,
        'Number of servers the bot is in.'
      )
    end
  end
end
