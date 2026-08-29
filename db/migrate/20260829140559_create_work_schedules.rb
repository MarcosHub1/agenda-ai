class CreateWorkSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :work_schedules, id: :uuid do |t|
      t.references :professional, null: false, foreign_key: true, type: :uuid
      t.integer :day_of_week, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.time :break_start
      t.time :break_end
      t.boolean :enabled, default: true, null: false

      t.timestamps
    end
    add_index :work_schedules, [ :professional_id, :day_of_week ], unique: true
  end
end
