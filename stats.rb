#!/usr/bin/env ruby
require 'bundler/setup'
require 'koala'

@graph = Koala::Facebook::API.new(ENV['FB_TOKEN'])

events = @graph.get_connections("me", "events/created")
allevents = []

print "."
while events.nil? == false do
  allevents += events.to_a
  events = events.next_page
  $stderr.print "."
end

allevents.select! { |e| e["name"] =~ Regexp.new(ARGV.first) } if ARGV.length > 0

$stderr.puts

$stderr.puts "Got #{allevents.length} events"

allevents.sort_by! { |e| e["start_time"] }

allevents.each_with_index do |e, i|
  $stderr.print "[#{i+1}/#{allevents.length}][#{e["start_time"]}] #{e["id"]}: #{e["name"]} "
  e["attending"] = @graph.get_connections(e["id"], "attending")
  $stderr.print "."
  e["maybe"] = @graph.get_connections(e["id"], "maybe")
  $stderr.print "."
  e["invited"] = @graph.get_connections(e["id"], "invited")
  $stderr.print "."
  $stderr.puts
end

tsv = allevents.map { |e| [e['start_time'].sub(/T.*/, ""), e["attending"].length, e["maybe"].length, e["invited"].length, e["name"].inspect, e['id']]}

puts "Date\tAttending\tMaybe\tInvited\tName\tId"
puts tsv.map { |row| row.join("\t")}.join("\n")