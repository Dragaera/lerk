require 'csv'

module Lerk
  module Hints
    class Parser
      def initialize(source: )
        @source = source
        @logger = ::Lerk.logger
      end

      def parse
        data = @source.contents

        @logger.info 'Parsing data'
        raw_data = data.lines

        # First three rows are headers / notes / empty
        3.times { raw_data.shift }

        hints = CSV.
          parse(raw_data.join("\n")).
          map do |ary|
          {
            identifier:     ary[0],
            text:           ary[2],
            tags:           ary[3].to_s.split(';').map(&:strip),
            group_basic:    ary[4] == 'TRUE',
            group_advanced: ary[5] == 'TRUE',
            group_veteran:  ary[6] == 'TRUE',
          }
        end

        hints_count = hints.length
        @logger.info "Got #{ hints_count } hints from file."

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

        hints.reject! do |hsh|
          hsh[:identifier].nil? || hsh[:identifier].empty?
        end
        @logger.info "Rejected #{ hints_count - hints.length } hints because no identifier."
        hints_count = hints.length

        hints.reject! do |hsh|
          hsh[:tags].empty?
        end
        @logger.info "Rejected #{ hints_count - hints.length } hints because no tags."
        hints_count = hints.length

        hints
      end
    end
  end
end
