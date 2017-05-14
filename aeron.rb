#!/usr/bin/env ruby
require_relative 'gumtree'
require_relative 'tracker'
require 'net/smtp'
require 'erb'
require 'json'
require 'logger'

log = Logger.new(STDOUT)

log.level = (ARGV.first == '-d') ? Logger::DEBUG : Logger::INFO


log.debug "Starting"

tracker = Tracker.new

def send_notifications(adverts)
  msg = <<~EOF
        From: "Gumtree Alert <gumtree@skrobul.com>"
        To: "Marek <skrobul@skrobul.com>"
        Subject: New matches

        I have found new matches:
        EOF
  adverts.each do |advert|
    msg += "\n#{advert[:price]} - #{advert[:title]}"
    msg += "\n#{advert[:location]} - #{advert[:posted]}"
    msg += "\n#{advert[:url]}"
    msg += "\n==================="
  end

  res = Net::SMTP.start('localhost', 25) do |smtp|
    smtp.send_message(msg, 'gumtree@skrobul.com', 'skrobul@skrobul.com')
  end
  # require 'pry'; binding.pry
end

new_ads = Gumtree.new.search('office-furniture-equipment', 'herman miller aeron').map do |advert|
  id = advert[:id]
  if tracker.already_processed?(id)
    log.debug "#{id} seen before, ignoring" 
    next
  else
    log.info "Found new ad #{id} - #{advert[:title]} price: #{advert[:price]}"
    tracker.process(id)
    advert
  end
end.compact

tracker.save
send_notifications(new_ads) unless new_ads.empty?
