class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :image_url
      t.string :slug
      t.text :description

      t.timestamps
    end
  end
end
