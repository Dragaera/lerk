module Lerk
  class HintTag < Sequel::Model
    many_to_many :hints

    def self.get_or_create(tag:)
      first(tag: tag) || HintTag.create(tag: tag)
    end
  end
end
