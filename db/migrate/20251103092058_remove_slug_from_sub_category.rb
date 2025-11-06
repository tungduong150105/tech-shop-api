class RemoveSlugFromSubCategory < ActiveRecord::Migration[8.1]
  def change
    remove_column :sub_categories, :slug
  end
end
