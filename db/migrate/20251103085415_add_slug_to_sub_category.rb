class AddSlugToSubCategory < ActiveRecord::Migration[8.1]
  def change
    add_column :sub_categories, :slug, :string
  end
end
