# frozen_string_literal: true

require "speaker/version"
require "speaker/platform"

#:nodoc:
module Speaker
  def self.usage
    warn "Usage: speaker [hi|bye]"
    exit(1)
  end

  def self.say(argv)
    usage if argv.size != 1
    phrases = []

    if argv.first == "hi"
      phrases << "Hello world"
    elsif argv.first == "bye"
      phrases << "Goodbye moon"
    else
      usage
    end

    phrases << Speaker::VERSION.split(".").last if Gem::Version.new(Speaker::VERSION).prerelease?

    phrases << Speaker::Platform.name
    puts phrases.join(", ")
  end
end
