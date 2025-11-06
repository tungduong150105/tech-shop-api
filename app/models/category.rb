class Category < ApplicationRecord
  has_many :products, dependent: :nullify
  has_many :sub_categories, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :image_url, presence: true
end
