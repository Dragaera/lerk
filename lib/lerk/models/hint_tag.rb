module Lerk
  class HintTag < Sequel::Model
    many_to_many :hints

    def validate
      super
      if self.class.where(Sequel.function(:lower, :tag) => tag.downcase).count > 0
        errors.add(:tag, 'Tag must be case-insensitively unique')
      end
    end

    def self.get_or_create(tag:)
      first(tag: tag) || HintTag.create(tag: tag)
    end
  end
end
