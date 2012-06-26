require 'rubygems'
require 'bundler'
Bundler.setup

require 'rspec'
require 'flail'

RSpec.configure do |config|
  config.mock_with :rr
end

