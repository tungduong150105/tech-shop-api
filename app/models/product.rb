class Product < ApplicationRecord
  belongs_to :category
  belongs_to :sub_category

  has_many :reviews, dependent: :destroy
  has_many :reviewers, through: :reviews, source: :user

  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :discount, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :sold, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :category_id, presence: true

  before_save :update_total_quantity
  before_save :add_product_spec
  after_initialize :set_defaults

  scope :available, -> { where("quantity > 0") }
  scope :popular, -> { order(sold: :desc) }
  scope :high_rated, -> { where("rating >= 4.0") }
  scope :on_sale, -> { where("discount > 0") }
  scope :by_category, ->(category_id) { where(category_id: category_id) }

  def add_product_spec
    self.specs.each { |value|
      ProductSpec.add_value_to_label(value["label"], self.category_id, value["value"])
    }
  end

  # Reviews
  def rating
    if reviews.none?
      return 0.0
    end
    reviews.average(:rating).to_f.round(1)
  end

  def update_rating
    self.rating = rating
  end

  def number_of_rating
    reviews.count
  end

  def add_review(user, rating, comment)
    review = review.find_or_initialize_by(user: user)
    review.rating = rating
    review.comment = comment

    if review.save
      true
    else
      false
    end
  end

  def update_review(user, rating, comment)
    review = reviews.find_by(user: user)
    return false unless review

    review.update(rating: rating, comment: comment)
  end

  def delete_review(user)
    review = reviews.find_by(user: user)
    return false unless review

    review.destroy
  end

  def user_review(user)
    reviews.find_by(user: user)
  end

  def has_user_reviewed?(user)
    reviews.exists?(user: user)
  end

  def recent_reviews(limit = 5)
    reviews.order(created_at: :desc).limit(limit).includes(:user)
  end

  def review_distribution
    distribution = { 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 }

    review.group(:rating).count.each do |rating, count|
      distribution[rating] = count
    end

    distribution
  end

  # Pricing and Stock
  def final_price
    price - (price * discount / 100)
  end

  def in_stock?
    quantity > 0
  end

  def update_color_quantity(color_name, new_quantity)
    color = find_color_by_name(color_name)
    return false unless color

    color["quantity"] = new_quantity.to_i
    save
  end

  def get_color_quantity(color_name)
    color = find_color_by_name(color_name)
    color ? color["quantity"].to_i : 0
  end

  def increase_color_quantity(color_name, amount)
    current_quantity = get_color_quantity(color_name)
    update_color_quantity(color_name, current_quantity + amount.to_i)
  end

  def decrease_color_quantity(color_name, amount)
    current_quantity = get_color_quantity(color_name)
    new_quantity = [ current_quantity - amount.to_i, 0 ].max
    update_color_quantity(color_name, new_quantity)
  end

  def color_in_stock?(color_name)
    get_color_quantity(color_name) > 0
  end

  def available_colors
    return [] unless color.present?
    color.select { |c| c["quantity"].to_i > 0 }
  end

  def total_color_quantity
    return 0 unless color.present?
    color.sum { |c| c["quantity"].to_i }
  end

  def add_sales(color_name, amount)
    return false if amount.to_i <= 0
    return false if find_color_by_name(color_name).nil?
    return false if get_color_quantity(color_name) < amount.to_i

    decrease_color_quantity(color_name, amount.to_i)

    self.sold += amount.to_i
    save
  end

  def find_color_by_name(color_name)
    return nil unless color.present?
    result = color.find { |c| c["name"] == color_name }
    puts "Result", result
    result
  end

  def update_total_quantity
    return unless color.present?
    self.quantity = total_color_quantity
  end

  # Defaults
  def set_defaults
    if color.present?
      self.color = color.map do |c|
        if c.is_a?(Hash)
          c["quantity"] ||= c["quantity"] if c["quantity"].present?
          c["quantity"] ||= 0
          c
        else
          { "name" => c, "code" => "#000000", "quantity" => 0 }
        end
      end
    end
    if self.rating.nil?
      self.rating ||= 0.0
    end
  end
end
