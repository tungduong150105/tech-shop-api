class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.decimal :price, null: false
      t.decimal :discount, default: 0.0
      t.integer :quantity, default: 0
      t.integer :sold, default: 0
      t.decimal :rating, default: 0.0
      t.integer :number_of_rating, default: 0
      t.text :img, array: true, default: []
      t.jsonb :specs, default: []
      t.jsonb :specs_detail, default: []
      t.jsonb :color, default: []
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
