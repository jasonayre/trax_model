require "bundler/gem_tasks"

namespace :db do
  desc "prepare"
  task :prepare do
    `psql postgresql://localhost:6432  -c 'CREATE DATABASE trax_model_tests;'`
  end
end
