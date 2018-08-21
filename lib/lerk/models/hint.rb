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

    def pretty_print
      out = []
      if group_basic
        out << '[Basic]'
      elsif group_advanced
        out << '[Advanced]'
      elsif group_veteran
        out << '[Veteran]'
      end

      if hint_tags_dataset.count > 0
        out << "(#{ hint_tags_dataset.select_map(:tag).join(', ') })"
      end

      out << text

      out.join(' ')
    end
  end
end
