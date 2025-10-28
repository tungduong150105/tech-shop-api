class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :price
      t.decimal :discount
      t.integer :quantity
      t.integer :sold
      t.decimal :rating
      t.text :img
      t.jsonb :specs
      t.jsonb :specs_detail
      t.jsonb :color

      t.timestamps
    end
  end
end
