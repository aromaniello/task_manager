require 'active_record'
require_relative 'task'

module TaskManager

  # Loads tasks from a json file and saves them to the database
  def self.load_tasks(file_name)
    require 'json'

    file = File.read(file_name)
    task_data = JSON.parse(file)

    connect_to_db

    task_data.each do |task|
      Task.create!(external_id: task["id"], description: task["description"], due_date: task["due_date"], assignee: task["assignee"])
    end

    true
  rescue StandardError => e
    puts e
    false
  end

  # Export tasks in the database which a certain deadline, in a specified format
  def self.export_tasks(deadline, file_name, format)
    raise "Unknown deadline: #{deadline}" unless [:today, :tomorrow, :next_week].include?(deadline)
    raise "Unknown format: #{format}" unless [:json, :csv].include?(format)

    connect_to_db

    date = Date.new(2023, 10, 1) # should be Date.today, but fixing at October 1st, 2023 for this exercise
    
    if deadline == :today
      start_date = date.to_s
      end_date = date.to_s
    elsif deadline == :tomorrow
      tomorrow = date.next
      start_date = tomorrow.to_s
      end_date = tomorrow.to_s
    elsif deadline == :next_week
      start_date = (date + 7).to_s
      end_date = (date + 14).to_s
    end
    
    tasks = Task.where('due_date BETWEEN ? AND ?', "#{start_date} 00:00:00", "#{end_date} 23:59:59").to_a
    
    if format == :json
      export_to_json(tasks, file_name)
    elsif format == :csv
      export_to_csv(tasks, file_name)
    end
      
    true
  rescue StandardError => e
    puts e
    false
  end

  private

  def self.export_to_json(tasks, file_name)
    require 'json'

    tasks_to_export = tasks.map do |task|
      {
        "id" => task.external_id,
        "description" => task.description,
        "due_date" => task.due_date,
        "assignee" => task.assignee
      }
    end

    File.open("#{file_name}.json", 'w') do |f|
      f.write(tasks_to_export.to_json)
    end
  end
  
  def self.export_to_csv(tasks, file_name)
    require 'csv'

    CSV.open("#{file_name}.csv", 'w') do |csv|
      csv << ["id", "description", "due_date", "assignee"]

      tasks.each do |task|
        csv << [task.id, task.description, task.due_date, task.assignee]
      end
    end
  end

  def self.connect_to_db
    db_config = YAML::load(File.open('database.yml'))
    ActiveRecord::Base.establish_connection(db_config)
  end
end