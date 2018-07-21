#!/usr/bin/env ruby

require 'config/boot'

source = Lerk::Hints::HTTPDownloadSource.new
# source = Lerk::Hints::LocalFileSource.new('/var/tmp/ns2_tips_sheet.csv')
parser = Lerk::Hints::Parser.new(source: source)

hints = parser.parse

puts "Got #{ hints.length } hints."
