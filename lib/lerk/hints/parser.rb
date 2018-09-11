require 'csv'

module Lerk
  module Hints
    class Parser
      TAG_SEPARATOR = ';'
      TAG_BLACKLIST = ['', '<>']

      # Enforcing a minimum length of two will prevent matching 'I'.
      VARIABLE_PLACEHOLDER_PATTERN = /[A-Z_]{2,}/
      BINDING_PLACEHOLDER_PATTERN = /BIND_[A-Za-z0-9]+/

      VARIABLE_FILE = 'data/hints/variables.json'
      BINDING_FILE  = 'data/hints/bindings.json'

      def initialize(source: , require_identifier: false, require_tags: false)
        @source             = source
        @require_tags       = require_tags
        @require_identifier = require_identifier

        @logger = ::Lerk.logger
        @existing_identifiers = Set.new

        @variables = JSON.parse(File.read(VARIABLE_FILE))
        @bindings  = JSON.parse(File.read(BINDING_FILE))
      end

      def parse
        data = @source.contents
        @existing_identifiers = Set.new

        @logger.info 'Parsing data'

        hints = CSV.parse(data).map do |ary|
          identifier = ary[0]
          text = ary[2]
          if identifier.nil? || identifier.empty?
            identifier = generate_identifier text
          end
          if @existing_identifiers.include? identifier
            identifier = generate_unique_identifier(text)
          end

          @existing_identifiers << identifier

          tags = ary[3].to_s.split(TAG_SEPARATOR) - TAG_BLACKLIST

          group_basic    = ary[4] == 'TRUE'
          group_advanced = ary[5] == 'TRUE'
          group_veteran  = ary[6] == 'TRUE'

          {
            identifier:     identifier,
            text:           text,
            tags:           tags,
            group_basic:    group_basic,
            group_advanced: group_advanced,
            group_veteran:  group_veteran,
          }
        end

        # First three rows are headers / notes / empty
        3.times { hints.shift }

        hints_count = hints.length
        @logger.info "Got #{ hints_count } hints from source."

        hints.reject! do |hsh|
          hsh[:text].nil? || hsh[:text].empty?
        end
        @logger.info "Rejected #{ hints_count - hints.length } hints because empty."
        hints_count = hints.length

        hints.select! do |hsh|
          hsh[:group_basic] || hsh[:group_advanced] || hsh[:group_veteran]
        end
        @logger.info "Rejected #{ hints_count - hints.length } hints because not game-ready."
        hints_count = hints.length

        if @require_identifier
          hints.reject! do |hsh|
            hsh[:identifier].nil? || hsh[:identifier].empty?
          end
          @logger.info "Rejected #{ hints_count - hints.length } hints because no identifier."
          hints_count = hints.length
        end

        if @require_tags
          hints.reject! do |hsh|
            hsh[:tags].empty?
          end
          @logger.info "Rejected #{ hints_count - hints.length } hints because no tags."
          hints_count = hints.length
        end

        hints.each do |hsh|
          hsh[:text] = process_placeholders(hsh[:text])
        end

        hints
      end

      private
      def generate_unique_identifier(text)
        identifier = generate_identifier(text)

        offset = 0
        while @existing_identifiers.include? identifier
          identifier = generate_identifier(text, offset: offset)
          offset += 1
        end

        identifier
      end

      def generate_identifier(text, offset: nil)
        # Prevents ID conflicts in case of duplicate hints without configured
        # identifiers.
        text << offset.to_s if offset
        digest = Digest::MD5.hexdigest text

        "_autogenerated_#{ digest }"
      end

      def replace_placeholder(text, placeholder, value)
        # Value might be a number.
        text.gsub!(placeholder, value.to_s)
      end

      def process_placeholders(text)
        @logger.debug "Scanning for placeholders: #{ text }"

        # Starting with the longest placeholder will ensure that, if we have
        # placeholders `A` and `A_B`, we won't replace the `A` part of `A_B`
        # with the value of `A`.
        # Alternatively we could ensure to only replace placeholders followed
        # by non-placeholder values, eg whitespace, punctuation marks and the
        # likes - but this feels a bit fragile.
        text.scan(VARIABLE_PLACEHOLDER_PATTERN).sort_by(&:length).reverse.each do |placeholder|
          if val = @variables[placeholder]
            @logger.debug "Replacing: #{ placeholder } = #{ val }"
            replace_placeholder(text, placeholder, val)
          else
            @logger.debug "Potential placeholder ignored: #{ placeholder }"
          end
        end

        text.scan(BINDING_PLACEHOLDER_PATTERN).sort_by(&:length).reverse.each do |placeholder|
          if val = @bindings[placeholder.gsub('BIND_', '')]
            @logger.debug "Replacing: #{ placeholder } = #{ val }"
            replace_placeholder(text, placeholder, val)
          else
            @logger.debug "Potential placeholder ignored: #{ placeholder }"
          end
        end

        text
      end
    end
  end
end