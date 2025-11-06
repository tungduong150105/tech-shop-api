# app/controllers/api/v1/carts_controller.rb
module Api::V1
  class CartsController < ApplicationController
    before_action :authenticate_user
    before_action :set_cart
    before_action :set_product, only: [ :add_item, :update_item, :remove_item ]

    # GET /api/v1/cart
    def show
      cart_items = @cart.cart_items.includes(:product)
      render json: {
        cart: cart_response(@cart, cart_items)
      }, status: :ok
    end

    # POST /api/v1/cart/add_item/:product_id
    def add_item
      quantity = params[:quantity].to_i.positive? ? params[:quantity].to_i : 1 
      color = params[:color]
      cart_item = @cart.add_product(@product, quantity, color)

      if cart_item.persisted?
        render json: {
          message: "Product added to cart successfully",
          cart_item: cart_item_response(cart_item),
          cart_summary: cart_summary(@cart)
        }, status: :created
      else
        render json: { errors: cart_item.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PUT /api/v1/cart/update_item/:product_id
    def update_item
      quantity = params[:quantity].to_i
      color = params[:color]

      if quantity <= 0
        @cart.remove_product(@product, color)
        render json: {
          message: "Product removed from cart",
          cart_summary: cart_summary(@cart)
        }, status: :ok
        return
      end

      if @cart.update_quantity(@product, quantity, color)
        cart_item = @cart.cart_items.find_by(product: @product, color: color)

        render json: {
          message: "Cart updated successfully",
          cart_item: cart_item_response(cart_item),
          cart_summary: cart_summary(@cart)
        }, status: :ok
      else
        render json: { errors: [ "Invalid quantity" ] }, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/cart/remove_item/:product_id
    def remove_item
      color = params[:color]
      @cart.remove_product(@product, color)

      render json: {
        message: "Product removed from cart",
        cart_summary: cart_summary(@cart)
      }, status: :ok
    end

    def checkout_eligibility
      if @cart.can_continue_checkout?
        render json: {
          eligible: true,
          message: "Cart is eligible for checkout"
        }, status: :ok
      else
        render json: {
          eligible: false,
          message: "Some items in the cart exceed available stock"
        }, status: :ok
      end
    end

    # DELETE /api/v1/cart/clear
    def clear
      @cart.clear
      render json: {
        message: "Cart cleared successfully",
        cart_summary: cart_summary(@cart)
      }, status: :ok
    end

    private

    def set_cart
      @cart = current_user.cart
    end

    def set_product
      @product = Product.find(params[:product_id])
    rescue ActiveRecord::RecordNotFound
      render json: { errors: [ "Product not found" ] }, status: :not_found
    end

    def cart_response(cart, cart_items)
      {
        id: cart.id,
        total_items: cart.total_items,
        total_price: cart.total_price,
        total_original_price: cart.total_original_price,
        total_discount: cart.total_discount,
        items: cart_items.map { |item| cart_item_response(item) }
      }
    end

    def cart_item_response(cart_item)
      product = cart_item.product
      {
        id: cart_item.id,
        product_id: product.id,
        name: product.name,
        price: product.price,
        final_price: product.final_price,
        discount: product.discount,
        quantity: cart_item.quantity,
        subtotal: cart_item.subtotal,
        unit_final_price: cart_item.unit_final_price,
        discount_amount: cart_item.discount_amount,
        image_url: product.img.first,
        stock_quantity: product.quantity,
        max_quantity: product.quantity,
        color: cart_item.color
      }
    end

    def cart_summary(cart)
      {
        total_items: cart.total_items,
        total_price: cart.total_price,
        total_original_price: cart.total_original_price,
        total_discount: cart.total_discount
      }
    end
  end
end

