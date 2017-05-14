require_relative 'gumtree'
require 'json'
require 'logger'

log = Logger.new(STDOUT)

log.level = (ARGV.first == '-d') ? Logger::DEBUG : Logger::INFO

TRACK_FILE = '.aeron_finder.json'

tracker = if File.exist?(TRACK_FILE)
  JSON.parse(File.read(TRACK_FILE))
else
  { 'processed' => [] }
end
log.debug "Starting"

Gumtree.new.search('office-furniture-equipment', 'herman miller aeron').each do |advert|
  id = advert[:id]
  if tracker['processed'].include?(id)
    log.debug "#{id} seen before, ignoring" 
    next
  else
    log.info "Found new ad #{id} - #{advert[:title]} price: #{advert[:price]}"
    tracker['processed'] << id
  end
end

File.open(TRACK_FILE, 'w') { |f| f.write(JSON.dump(tracker)) }
