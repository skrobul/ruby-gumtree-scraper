class Tracker
  TRACK_FILE = '.aeron_finder.json'

  def initialize
    @processed = []
    load
  end

  def load
    ret = JSON.parse(File.read(TRACK_FILE)) if File.exist?(TRACK_FILE)
    @processed = (ret && ret['processed']) || []
  end

  def already_processed?(id)
    @processed.include? id
  end

  def process(id)
    @processed << id
  end

  def save
    File.open(TRACK_FILE, 'w') { |f| f.write(JSON.dump(processed: @processed)) }
  end
end


