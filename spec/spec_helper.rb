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
ENV["DB_PORT"] = (ENV["DB"] == "postgres" && ENV["CI"] == "true") ? "5432" : "6432"
ENV["DATABASE_URL"] = "postgres://postgres@localhost:#{ENV['DB_PORT']}/trax_model_tests"

RSpec.configure do |config|
  config.filter_run :focus
  config.filter_run_excluding :postgres => true unless ENV["DB"] == "postgres"
  config.run_all_when_everything_filtered = true

  config.before(:suite) do
    db_config = ::YAML::load(::ERB.new(::File.read("#{File.dirname(__FILE__)}/db/database.yml")).result)

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
