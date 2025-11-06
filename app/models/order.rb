class Order < ApplicationRecord
  belongs_to :user

  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :order_number, presence: true, uniqueness: true
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending confirmed processing shipped delivered cancelled] }
  validates :payment_method, presence: true, inclusion: { in: %w[credit_card paypal cash_on_delivery bank_transfer] }

  before_validation :generate_order_number, on: :create
  before_save :calculate_total_amount, if: -> { order_items.any? }

  scope :recent, -> { order(created_at: :desc) }
  scope :pending, -> { where(status: "pending") }
  scope :confirmed, -> { where(status: "confirmed") }
  scope :processing, -> { where(status: "processing") }
  scope :shipped, -> { where(status: "shipped") }
  scope :delivered, -> { where(status: "delivered") }
  scope :cancelled, -> { where(status: "cancelled") }
  scope :by_user, ->(user_id) { where(user_id: user_id) }

  def self.create_from_cart(user, order_params = {})
    transaction do
      cart = user.cart

      return if cart.cart_items.empty?

      order = user.orders.create!(
        total_amount: cart.total_price,
        status: "pending",
        **order_params
      )

      cart.cart_items.each do |cart_item|
        product = cart_item.product

        order.order_items.create!(
          product: product,
          quantity: cart_item.quantity,
          unit_price: product.final_price,
          total_price: cart_item.subtotal,
          color: { "name" => cart_item.color["name"], "code" => cart_item.color["code"] }
        )

        product.decrease_color_quantity(cart_item.color["name"], cart_item.quantity)
      end

      cart.clear

      order
    end
  end

  def confirm!
    update(status: "confirmed")
  end

  def process!
    update(status: "processing")
  end

  def ship!
    update(status: "shipped")
  end

  def deliver!
    update(status: "delivered")
  end

  def cancel!
    update(status: "cancelled")
    restore_stock
  end

  def pending?
    status == "pending"
  end

  def confirmed?
    status == "confirmed"
  end

  def can_cancel?
    %w[pending confirmed].include?(status)
  end

  def items_count
    order_items.sum(:quantity)
  end

  def shipping_address_formatted
    return "" unless shipping_address.present?

    address = shipping_address
    [
      address["street"],
      address["city"],
      address["state"],
      address["zip_code"],
      address["country"]
    ].compact.join(", ")
  end

  private

  def generate_order_number
    return if order_number.present?

    loop do
      self.order_number = "ORD-#{Time.now.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
      break unless Order.exists?(order_number: order_number)
    end
  end

  def calculate_total_amount
    self.total_amount = order_items.sum(:total_price)
  end

  def restore_stock
    order_items.each do |item|
      product = item.product
      if item.color.present?
        product.increase_color_quantity(item.color, item.quantity)
      else
        product.update(quantity: product.quantity + item.quantity)
      end
    end
  end
end
