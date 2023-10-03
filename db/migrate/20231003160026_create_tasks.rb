class CreateTasks < ActiveRecord::Migration[7.0]
  def self.up
    create_table :tasks do |t|
      t.integer "external_id"
      t.string "description"
      t.datetime "due_date"
      t.string "assignee"
    end
  end
end
