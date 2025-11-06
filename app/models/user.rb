class User < ApplicationRecord
  has_secure_password

  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :reviewed_products, through: :reviews, source: :product
  has_many :ordered_products, through: :orders, source: :products
  has_one :cart, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :password, length: { minimum: 8 }
  validates :role, inclusion: { in: %w[admin customer] }

  before_validation :set_default_role
  after_create :create_cart

  def create_cart
    Cart.create(user: self)
  end

  def admin?
    role == "admin"
  end

  def customer?
    role == "customer"
  end

  def generate_auth_token
    JWT.encode({ user_id: id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_generate_token)
  end

  def self.from_token(token)
    begin
      decode = JWT.decode(token, Rails.application.credentials.secret_key_generate_token)[0]
      find(decode["user_id"])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      nil
    end
  end

  def set_default_role
    self.role ||= "customer"
  end
end
