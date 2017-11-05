# coding: utf-8

require 'rack'
require 'prometheus/middleware/exporter'

module Lerk
  module PrometheusExporter
    def self.run_exporter
      # Mind the uppercase `:Port`
      Rack::Handler::WEBrick.run(app, Port: Config::Prometheus::PORT)
    end

    private
    def self.app
      Rack::Builder.new do
        use Prometheus::Middleware::Exporter

        run ->(_) { [200, {'Content-Type' => 'text/html'}, ['OK']] }
      end.to_app
    end
  end
end
