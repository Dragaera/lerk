module Lerk
  class Hint < Sequel::Model
    many_to_many :hint_tags

    def self.get_or_create(identifier:, **kwargs)
      first(identifier: identifier) || Hint.create(
        identifier:     identifier,
        text:           kwargs.fetch(:text),
        group_basic:    kwargs.fetch(:group_basic),
        group_advanced: kwargs.fetch(:group_advanced),
        group_veteran:  kwargs.fetch(:group_veteran),
      )
    end
  end
end
