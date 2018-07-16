#!/usr/bin/env ruby

SHEET_DOWNLOAD_URL = 'https://docs.google.com/spreadsheets/d/1avfd3taTetnCofE9AZIJUd8Z3lyX6Y7EehZIu6dBfpw/gviz/tq?tqx=out:csv&sheet=Tip-List&headers=0'

require 'pry'
require 'csv'

raw_data = IO.readlines('/var/tmp/ns2_tips_sheet.csv')

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
  end.select do |hsh|
    hsh[:text] && !hsh[:text].empty? && (hsh[:group_basic] || hsh[:group_advanced] || hsh[:group_veteran])
  end

# hints.each do |hsh|
#   puts "#{ hsh[:identifier] } (#{ hsh[:tags].join(', ') }): #{ hsh[:text] }"
# end

puts "Hints ready for ingame: #{ hints.count }"
no_variable_count = hints.select { |hsh| hsh[:identifier].nil? || hsh[:identifier].empty? }.count
puts "Hints without variable / identifier: #{ no_variable_count }"
no_tags_count = hints.select { |hsh| hsh[:tags].empty? }.count
puts "Hints without tags: #{ no_tags_count }"
