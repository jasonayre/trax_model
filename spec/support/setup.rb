require 'active_record'

::ActiveRecord::Schema.define(:version => 1) do
  require_relative '../db/schema/default_tables'
  instance_eval(&DEFAULT_TABLES)

  if ENV["DATABASE"] == "postgres"
    require_relative '../db/schema/pg_tables'
    instance_eval(&PG_TABLES)
  end
end
