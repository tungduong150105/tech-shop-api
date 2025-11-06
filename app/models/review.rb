class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :rating, presence: true, numericality: {
    only_integer: true,
    greater_than: 0,
    less_than_or_equal_to: 5
  }
  validates :comment, presence: true, length: { maximum: 1000 }, allow_blank: true
  validates :user_id, uniqueness: { scope: :product_id, message: "has already reviewed this product" }

  scope :recent, -> { order(created_at: :desc) }
  scope :high_rating, -> { where("rating >= ?", 4) }

  after_save :update_rating
  after_destroy :update_rating

  def update_rating
    product.update_rating
  end
end
