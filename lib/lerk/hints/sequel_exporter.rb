module Lerk
  module Hints
    class SequelExporter
      def initialize(hints)
        @hints = hints

        @logger = ::Lerk.logger
        @tag_cache = {}
      end

      def export(truncate: true)
        if truncate
          truncate_hints
          truncate_tags
        end

        export_hint_tags
        export_hints
      end

      private
      def truncate_hints
        # This'll also truncate the hint-tag join table.
        Hint.truncate(cascade: true)
      end

      def truncate_tags
        HintTag.truncate(cascade: true)
      end

      def export_hint_tags
        tags = Set.new
        @hints.each do |hsh|
          tags.merge(hsh[:tags])
        end

        # Not the most efficient way (compared with eg a bulk query + insert),
        # but as the number of unique tags will be low, this is fine.
        tags.each do |tag|
          @tag_cache[tag] = HintTag.get_or_create(tag: tag)
        end
      end

      def export_hints
        @hints.each do |hsh|
          hint = Hint.get_or_create(hsh)
          hint.update(
            text:           hsh.fetch(:text),
            group_basic:    hsh.fetch(:group_basic),
            group_advanced: hsh.fetch(:group_advanced),
            group_veteran:  hsh.fetch(:group_veteran),
          )

          hint.hint_tags.each do |existing_tag|
            unless hsh[:tags].include? existing_tag.tag
              hint.remove_hint_tag(existing_tag)
            end
          end

          hsh[:tags].each do |tag|
            tag_obj = @tag_cache.fetch(tag)
            unless hint.hint_tags.include? tag_obj
              hint.add_hint_tag(tag_obj)
            end
          end
        end
      end
    end
  end
end
