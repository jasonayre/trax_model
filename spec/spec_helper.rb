require 'rubygems'
require 'bundler'
require 'simplecov'
require 'pry'
require 'trax_model'
require 'active_record'

SimpleCov.start do
  add_filter '/spec/'
end

RSpec.configure do |config|

  config.before(:suite) do
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database => "spec/test.db"
    )

    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end

    ::Trax::Model.configure do |config|
      config.auto_include = false
    end


    ::Dir["#{::File.dirname(__FILE__)}/support/*.rb"].each { |f| require f }
  end

  # Kernel.srand config.seed
end

Bundler.require(:default, :development, :test)
