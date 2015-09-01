require 'rubygems'
require 'bundler'
require 'simplecov'
# require 'pry'
require 'trax_model'
require 'active_record'

SimpleCov.start do
  add_filter '/spec/'
end

ENV["DATABASE"] ||= "sqllite"
ENV["DATABASE"] = "postgres" if ENV["DATABASE"] == "pg" || ENV["PG"]
ENV["DB"] = ENV["DATABASE"]

RSpec.configure do |config|

  config.filter_run_excluding :postgres => true unless ENV["DATABASE"] == "postgres"

  config.before(:suite) do
    db_config = YAML::load(
      ::File.open("#{File.dirname(__FILE__)}/db/database.yml")
    )

    ::ActiveRecord::Base.establish_connection(db_config[ENV["DATABASE"]])

    # ::ActiveRecord::Base.establish_connection(pg_config["test"])

    # ::ActiveRecord::Base.establish_connection(
    #   :adapter => "sqlite3",
    #   :database => "spec/test.db"
    # )

    # connection = ::ActiveRecord::Base.connection
    # # drop_db = "DROP DATABASE trax_model_test"
    # create_db = "CREATE DATABASE trax_model_test"
    # connection.execute(create_db)

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
