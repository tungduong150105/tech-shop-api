class RemoveSlugFromCategory < ActiveRecord::Migration[8.1]
  def change
    remove_column :categories, :slug
  end
end
