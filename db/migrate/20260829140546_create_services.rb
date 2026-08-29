class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.text :description
      t.integer :duration_minutes, default: 30, null: false
      t.integer :price_cents, default: 0, null: false
      t.string :currency, default: "BRL", null: false
      t.boolean :active, default: true, null: false
      t.integer :sort_order, default: 0, null: false

      t.timestamps
    end
    add_index :services, [ :account_id, :sort_order ]
  end
end
