class RemoveRatingFromProducts < ActiveRecord::Migration[8.1]
  def change
    remove_column :products, :rating, :decimal
    remove_column :products, :number_of_rating, :integer
  end
end
