#!/usr/bin/env ruby
require_relative 'gumtree'
require_relative 'tracker'
require 'json'
require 'logger'

log = Logger.new(STDOUT)

log.level = (ARGV.first == '-d') ? Logger::DEBUG : Logger::INFO


log.debug "Starting"

tracker = Tracker.new

Gumtree.new.search('office-furniture-equipment', 'herman miller aeron').each do |advert|
  id = advert[:id]
  if tracker.already_processed?(id)
    log.debug "#{id} seen before, ignoring" 
    next
  else
    log.info "Found new ad #{id} - #{advert[:title]} price: #{advert[:price]}"
    tracker.process(id)
  end
end
tracker.save
