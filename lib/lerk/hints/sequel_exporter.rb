module Lerk
  module Hints
    class SequelExporter
      def initialize(hints)
        @hints = hints

        @logger = ::Lerk.logger
        @tag_cache = {}
      end

      def export
        truncate_hints
        truncate_tags

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

        # Prevents import issues due to inconsistent capitalization.
        tags.map! { |tag| tag.downcase }

        # Not the most efficient way (compared with eg a bulk query + insert),
        # but as the number of unique tags will be low, this is fine.
        tags.each do |tag|
          @tag_cache[tag] = HintTag.create(tag: tag)
        end
      end

      def export_hints
        @hints.each do |hsh|
          hint = Hint.create(
            identifier:     hsh.fetch(:identifier),
            text:           hsh.fetch(:text),
            group_basic:    hsh.fetch(:group_basic),
            group_advanced: hsh.fetch(:group_advanced),
            group_veteran:  hsh.fetch(:group_veteran),
          )

          hsh[:tags].each do |tag|
            tag_obj = @tag_cache.fetch(tag.downcase)
            hint.add_hint_tag(tag_obj)
          end
        end
      end
    end
  end
end
