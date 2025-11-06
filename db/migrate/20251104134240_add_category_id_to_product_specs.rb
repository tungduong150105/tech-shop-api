class AddCategoryIdToProductSpecs < ActiveRecord::Migration[8.1]
  def change
    add_column :product_specs, :category_id, :integer
  end
end
