module Lerk
  module Hints
    class LocalFileSource
      def initialize(path)
        @path = path
      end

      def contents
        IO.read(@path)
      end
    end
  end
end
