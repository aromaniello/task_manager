
require 'active_record'
require_relative 'task_manager'

namespace :db do
  db_config = YAML::load(File.open('database.yml'))
  db_config_admin = db_config.merge({'database' => 'postgres', 'schema_search_path' => 'public'})

  desc "Creates the database"
  task :create do
    ActiveRecord::Base.establish_connection(db_config_admin)
    ActiveRecord::Base.connection.create_database(db_config['database'])
  end

  desc "Drops the database"
  task :drop do
    ActiveRecord::Base.establish_connection(db_config_admin)
    ActiveRecord::Base.connection.drop_database(db_config["database"])
  end

  desc "Runs all pending migrations"
  task :migrate do
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::MigrationContext.new("db/migrate/", ActiveRecord::SchemaMigration).migrate
  end

  desc "Generates a new migration file"
  task :generate_migration do
    name = ARGV[1] || raise("Usage: rake db:generate_migration name_of_migration")
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    path = File.expand_path("../db/migrate/#{timestamp}_#{name}.rb", __FILE__)
    migration_class = name.split("_").map(&:capitalize).join

    File.open(path, 'w') do |file|

      file.write <<-EOF
class #{migration_class} < ActiveRecord::Migration[7.0]
  def self.change
  end
end
EOF
    end
    abort
  end
end

desc "Imports tasks from a json file"
task :load_tasks do
  file_name = ARGV[1] || raise("Usage: rake load_tasks name_of_file")
  ARGV.each { |a| task a.to_sym do ; end }

  if TaskManager.load_tasks(file_name)
    puts "Tasks imported successfully"
  end
end

desc "Exports tasks for a specified deadline in json or csv"
task :export_tasks do
  unless ARGV.length == 4 &&
         ["today", "tomorrow", "next_week"].include?(ARGV[1]) &&
         ["json", "csv"].include?(ARGV[3])
    raise("Usage: rake export_tasks today|tomorrow|next_week file_name json|csv")
  end
  ARGV.each { |a| task a.to_sym do ; end }
  
  deadline = ARGV[1].to_sym
  file_name = ARGV[2]
  file_format = ARGV[3].to_sym

  if TaskManager.export_tasks(deadline, file_name, file_format)
    puts "Tasks exported successfully"
  end
end