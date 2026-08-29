class CreateProfessionalServices < ActiveRecord::Migration[8.1]
  def change
    create_table :professional_services, id: :uuid do |t|
      t.references :professional, null: false, foreign_key: true, type: :uuid
      t.references :service, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
    add_index :professional_services, [ :professional_id, :service_id ], unique: true
  end
end
