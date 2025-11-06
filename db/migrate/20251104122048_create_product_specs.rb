class CreateProductSpecs < ActiveRecord::Migration[8.1]
  def change
    create_table :product_specs do |t|
      t.string :label
      t.jsonb :value, default: []

      t.timestamps
    end
  end
end
