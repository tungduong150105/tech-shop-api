class Product < ApplicationRecord
  belongs_to :category

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :discount, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :sold, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }

  # serialize :img, Array
  # serialize :specs, Array
  # serialize :specs_detail, Array
  # serialize :color, Array

  scope :available, -> { where('quantity > 0') }
  scope :popular, -> { order(sold: :desc) }
  scope :high_rated, -> { where('rating >= 4.0') }
  scope :on_sale, -> { where('discount > 0') }

  def final_price
    price - (price * discount / 100)
  end

  def in_stock?
    quantity > 0
  end

  def add_to_sold(amount)
    update(sold: sold + amount, quantity: quantity - amount)
  end

  def update_rating(new_rating)
    total_ratings = sold > 0 ? sold : 1
    new_average = ((rating * (total_ratings - 1)) + new_rating) / total_ratings
    update(rating: new_average.round(1))
  end

  def main_image
    img.first if img.present?
  end

  def available_colors
    color.map { |c| c['name'] } if color.present?
  end

  # Helper methods for filtering
  def self.filter_by_spec_value(spec_label, values)
    where("EXISTS (SELECT 1 FROM jsonb_array_elements(specs) AS spec WHERE spec->>'label' = ? AND spec->>'value' IN (?))", spec_label, values)
  end

  def get_spec_value(label)
    spec = specs.find { |s| s['label'] == label }
    spec['value'] if spec
  end

  # Common spec getters
  def brand
    get_spec_value('Brand')
  end

  def ram
    get_spec_value('RAM') || get_spec_value('Memory')
  end

  def processor
    get_spec_value('Processor') || get_spec_value('CPU')
  end

  def storage
    get_spec_value('Storage') || get_spec_value('SSD') || get_spec_value('HDD')
  end

  def screen_size
    get_spec_value('Display') || get_spec_value('Screen')
  end

  def gpu
    get_spec_value('GPU') || get_spec_value('Graphics')
  end
end