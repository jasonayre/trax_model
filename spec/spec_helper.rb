require 'rubygems'
require 'bundler'
require 'simplecov'
require 'pry'
require 'trax_model'

SimpleCov.start do
  add_filter '/spec/'
end

RSpec.configure do |config|
  config.before(:suite) do
  end
end

Bundler.require(:default, :development, :test)

::Dir["#{::File.dirname(__FILE__)}/support/*.rb"].each {|f| require f }
