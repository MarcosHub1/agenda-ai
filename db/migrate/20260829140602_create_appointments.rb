class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.references :professional, null: false, foreign_key: true, type: :uuid
      t.references :service, null: false, foreign_key: true, type: :uuid
      t.references :client, null: false, foreign_key: true, type: :uuid
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :status, default: 0, null: false
      t.integer :price_cents, default: 0, null: false
      t.string :cancellation_reason
      t.text :notes
      t.json :metadata

      t.timestamps
    end
    add_index :appointments, [ :account_id, :professional_id, :starts_at ]
    add_index :appointments, [ :professional_id, :starts_at, :ends_at ]
    add_index :appointments, [ :account_id, :status ]
  end
end
