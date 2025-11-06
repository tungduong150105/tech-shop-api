class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :order_number
      t.decimal :total_amount
      t.string :status
      t.jsonb :shipping_address
      t.string :payment_method

      t.timestamps
    end
  end
end
