class CreateSubCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :sub_categories do |t|
      t.string :name
      t.string :image_url
      t.text :description
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
