class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :cart_id, presence: true
  validates :product_id, presence: true
  validates :color, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validate :quantity_does_not_exceed_stock

  validates :product_id, uniqueness: { scope: [ :cart_id, :color ], message: "is already in your cart" }

  def subtotal
    quantity * product.final_price
  end

  def unit_final_price
    product.final_price
  end

  def discount_amount
    quantity * (product.price - product.final_price)
  end

  def available_quantity
    color_data = product.color.find { |c| c["name"] == color["name"] }
    color_data ? color_data["quantity"] : 0
  end

  private

  def quantity_does_not_exceed_stock
    return unless product && quantity.present?
    
    available_qty = available_quantity
    if quantity > available_qty
      errors.add(:quantity, "cannot exceed available stock of #{available_qty}")
    end
  end
end
