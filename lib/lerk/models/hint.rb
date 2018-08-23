module Lerk
  class Hint < Sequel::Model
    many_to_many :hint_tags

    EXISTING_HINT_GROUPS = [:basic, :advanced, :veteran]

    def self.get_or_create(identifier:, **kwargs)
      first(identifier: identifier) || Hint.create(
        identifier:     identifier,
        text:           kwargs.fetch(:text),
        group_basic:    kwargs.fetch(:group_basic),
        group_advanced: kwargs.fetch(:group_advanced),
        group_veteran:  kwargs.fetch(:group_veteran),
      )
    end

    def self.find(group: nil, tag: nil)
      group = sanitize_group(group)
      tag   = sanitize_tag(tag)

      if tag
        hints = HintTag.first(tag: tag).hints_dataset
      else
        hints = Hint.dataset
      end

      if group
        if group == :basic
          hints = hints.where(group_basic: true)
        elsif group == :advanced
          hints = hints.where(group_advanced: true)
        elsif group == :veteran
          hints = hints.where(group_veteran: true)
        end
      end

      hints
    end

    def pretty_print
      group = if group_basic
                '[Basic]'
              elsif group_advanced
                '[Advanced]'
              elsif group_veteran
                '[Veteran]'
              end

      tags = if hint_tags_dataset.count > 0
               "(#{ hint_tags_dataset.select_map(:tag).join(', ') })"
             else
               nil
             end

      header = [group, tags].compact.join(' ')

      "**#{ group } #{ tags }**\n#{ text }"
    end

    private
    def self.sanitize_group(group)
      return nil unless group

      if EXISTING_HINT_GROUPS.include? group
        group
      else
        raise ArgumentError, "Unknown group: #{ group }"
      end
    end

    def self.sanitize_tag(tag)
      return nil unless tag

      tag.downcase!
      existing_tags = Set.new(HintTag.select_map(:tag))
      if existing_tags.include? tag
        tag
      else
        raise ArgumentError, "Unknown tag: #{ tag }"
      end
    end
  end
end
