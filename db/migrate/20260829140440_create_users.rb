class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.integer :role, default: 0
      t.string :email_address, null: false
      t.string :password_digest, null: false

      t.timestamps
    end
    add_index :users, [ :account_id, :email_address ], unique: true
  end
end
