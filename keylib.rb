# Note Queue Key Library: Manages local storage of API keys for accessing the server.
# Author: Cameron Carroll, December 2015

KEY_LOCATION = Dir.home + '/.notequeue_keys'

module NQKeylib

  @@key, @@secret = nil

  def self.keys
    keys_exist? ? load_keys : get_keys
    [@@key, @@secret]
  end

  private

  def self.keys_exist?
    File.exists? KEY_LOCATION
  end

  # TODO: Validate key/secret are correct length and format?
  def self.get_keys
    puts "I couldn't find your API key/ID and your secret."
    puts "Please copy the key off of the website and paste it here..."
    print "API KEY: "
    @@key = gets.chomp
    puts "Thanks, now please copy the secret off of the website and paste it here..."
    print "SECRET: "
    @@secret = gets.chomp
    save_keys
  end

  def self.load_keys
    data = File.read(KEY_LOCATION)
    data = data.split(':')
    if data.length == 2
      @@key = data[0]
      @@secret = data[1]
    end
  end

  def self.save_keys
    File.write(KEY_LOCATION, "#{@@key}:#{@@secret}")
  end


end
