require 'logger'

# rubocop:disable ClassVars
module GrapeLogger
  def self.logger
    @@logger ||= init
  end

  def self.logger=(logger)
    @@logger = logger
  end

  def self.init
    path = File.expand_path("#{Rack::Directory.new('').root}/log/#{ENV['RACK_ENV']}.log")
    path = "| tee #{path}" unless ENV['RACK_ENV'] == 'test'
    Logger.new(path)
  end
end
# rubocop:enable ClassVars
