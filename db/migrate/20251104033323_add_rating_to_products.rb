class AddRatingToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :rating, :decimal
  end
end
