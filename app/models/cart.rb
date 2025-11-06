class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :user_id, presence: true, uniqueness: true

  def add_product(product, quantity = 1, color)
    cart_item = cart_items.find_or_initialize_by(product: product, color: color)
    cart_item.quantity = cart_item.persisted? ? cart_item.quantity + quantity : quantity
    cart_item.save
    cart_item
  end

  def can_continue_checkout?
    cart_items.all? do |item|
      return false if item.quantity > item.available_quantity
    end
    true
  end

  def remove_product(product, color)
    cart_items.where(product: product, color: color).destroy_all
  end

  def update_quantity(product, quantity, color)
    cart_item = cart_items.find_by(product: product, color: color)
    if cart_item && quantity > 0
      cart_item.update(quantity: quantity)
    elsif cart_item && quantity <= 0
      cart_item.destroy
    end
  end

  def total_price
    cart_items.sum(&:subtotal)
  end

  def total_original_price
    cart_items.joins(:product).sum("cart_items.quantity * products.price")
  end

  def total_discount
    total_original_price - total_price
  end

  def total_items
    cart_items.sum(:quantity)
  end

  def clear
    cart_items.destroy_all
  end

  def empty?
    cart_items.empty?
  end
end
