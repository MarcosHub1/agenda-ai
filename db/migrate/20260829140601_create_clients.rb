class CreateClients < ActiveRecord::Migration[8.1]
  def change
    create_table :clients, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.text :notes

      t.timestamps
    end
    add_index :clients, [ :account_id, :email ]
    add_index :clients, [ :account_id, :phone ]
  end
end
