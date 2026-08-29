# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.references :account, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.integer :plan_interval, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.string :stripe_customer_id
      t.string :stripe_subscription_id
      t.string :stripe_price_id
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.boolean :cancel_at_period_end, default: false, null: false

      t.timestamps
    end

    add_index :subscriptions, :stripe_customer_id
    add_index :subscriptions, :stripe_subscription_id
    add_index :subscriptions, :status
  end
end
