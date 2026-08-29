class CreateScheduleExceptions < ActiveRecord::Migration[8.1]
  def change
    create_table :schedule_exceptions, id: :uuid do |t|
      t.references :professional, null: false, foreign_key: true, type: :uuid
      t.date :exception_date, null: false
      t.boolean :is_blocked, default: true, null: false
      t.time :start_time
      t.time :end_time
      t.string :reason

      t.timestamps
    end
    add_index :schedule_exceptions, [ :professional_id, :exception_date ]
  end
end
