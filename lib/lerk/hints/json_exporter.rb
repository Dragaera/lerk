module Lerk
  module Hints
    class JSONExporter
      def initialize(hints)
        @hints = hints
      end

      def export
        @hints.to_json
      end
    end
  end
end
