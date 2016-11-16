require 'rubygems'
require 'bundler'
require 'simplecov'
# require 'pry'
require 'trax_model'
require 'timecop'
require 'rails'
require 'active_record'
::Rails.cache = ::ActiveSupport::Cache::MemoryStore.new
::Trax::Model.cache = ::Rails.cache

SimpleCov.start do
  add_filter '/spec/'
end

ENV["DB"] ||= "sqllite"
ENV["DB"] = "postgres" if ENV["DB"] == "pg" || ENV["pg"] == "true"

if ENV["DB"] == "postgres" && ENV["CI"] == "true"
  ENV["DATABASE_URL"] = "localhost"
else
  ENV["DATABASE_URL"] = "localhost:6432"
end

RSpec.configure do |config|
  config.filter_run :focus
  config.filter_run_excluding :postgres => true unless ENV["DB"] == "postgres"
  config.run_all_when_everything_filtered = true

  config.before(:suite) do
    db_config = ::YAML::load(::File.open("#{File.dirname(__FILE__)}/db/database.yml"))

    ::ActiveRecord::Base.establish_connection(db_config[ENV["DB"]])

    ::ActiveRecord::Base.connection.tables.each do |table|
      ::ActiveRecord::Base.connection.drop_table(table)
    end

    ::Trax::Model.configure do |config|
      config.auto_include = false
    end

    ::Dir["#{::File.dirname(__FILE__)}/support/*.rb"].each { |f| require f }
  end
end

Bundler.require(:default, :development, :test)
