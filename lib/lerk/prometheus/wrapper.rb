# coding: utf-8

module Lerk
  module Prometheus
    class Wrapper
      @@default_wrapper = nil

      def self.default
        @@default_wrapper || @@default_wrapper = Wrapper.new
      end

      def initialize
        @registry = ::Prometheus::Client.registry
      end

      def counter(*args)
        cnt = DiscordCounter.new(*args)
        @registry.register(cnt)
      end

      def gauge(*args)
        gauge = ::Prometheus::Client::Gauge.new(*args)
        @registry.register(gauge)
      end

      def histogram(*args)
        hist = DiscordHistogram.new(*args)
        @registry.register(hist)
      end
    end
  end
end
