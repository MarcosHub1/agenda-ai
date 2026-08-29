class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts, id: :uuid do |t|
      t.string :name
      t.string :slug
      t.string :logo_url
      t.string :timezone
      t.string :currency
      t.json :settings
      t.integer :status

      t.timestamps
    end
    add_index :accounts, :slug, unique: true
  end
end
