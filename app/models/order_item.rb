class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  # Validations
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :color, presence: true, if: -> { product&.color.present? }

  # Callbacks
  before_validation :set_prices, on: :create

  # Instance methods
  def subtotal
    unit_price * quantity
  end

  private

  def set_prices
    return unless product

    self.unit_price ||= product.final_price
    self.total_price ||= unit_price * quantity
  end
end
