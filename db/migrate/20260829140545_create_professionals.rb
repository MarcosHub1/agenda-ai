class CreateProfessionals < ActiveRecord::Migration[8.1]
  def change
    create_table :professionals, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.references :user, null: true, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :email
      t.string :avatar_url
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    add_index :professionals, [ :account_id, :email ]
  end
end
