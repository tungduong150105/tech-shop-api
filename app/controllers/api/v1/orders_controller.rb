module Api::V1
  class OrdersController < ApplicationController
    before_action :set_order, only: [ :show, :cancel, :update_status ]

    # GET /api/v1/orders
    def index
      if current_user.admin?
        @orders = Order.includes(:user, :order_items, :products).recent
      else
        @orders = current_user.orders.includes(:order_items, :products).recent
      end

      @orders = @orders.page(params[:page]).per(params[:limit] || 20)

      render json: {
        orders: @orders.as_json(include: {
          user: { only: [ :id, :name, :email ] },
          order_items: { include: { product: { only: [ :id, :name, :img ] } } }
        }),
        pagination: {
          current_page: @orders.current_page,
          total_pages: @orders.total_pages,
          total_count: @orders.total_count
        }
      }
    end

    # GET /api/v1/orders/:id
    def show
      render json: @order.as_json(include: {
        user: { only: [ :id, :name, :email, :phone ] },
        order_items: {
          include: {
            product: {
              only: [ :id, :name, :img, :price ],
              methods: [ :final_price ]
            }
          }
        }
      })
    end

    # POST /api/v1/orders
    def create
      Order.transaction do
        @order = Order.create_from_cart(current_user, order_params)

        render json: {
          success: true,
          message: "Order created successfully",
          order: @order.as_json(include: {
            order_items: { include: { product: { only: [ :id, :name ] } } }
          })
        }, status: :created
      end
    rescue => e
      render json: {
        success: false,
        error: "Failed to create order: #{e.message}"
      }, status: :unprocessable_entity
    end

    # PATCH /api/v1/orders/:id/cancel
    def cancel
      unless @order.can_cancel?
        render json: {
          success: false,
          error: "Order cannot be cancelled at this stage"
        }, status: :unprocessable_entity
        return
      end

      if @order.cancel!
        render json: {
          success: true,
          message: "Order cancelled successfully",
          order: @order
        }
      else
        render json: {
          success: false,
          errors: @order.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    # PATCH /api/v1/orders/:id/update_status
    def update_status
      require_admin

      if @order.update(status: params[:status])
        render json: {
          success: true,
          message: "Order status updated successfully",
          order: @order
        }
      else
        render json: {
          success: false,
          errors: @order.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    # GET /api/v1/orders/stats
    def stats
      require_admin

      stats = {
        total_orders: Order.count,
        pending_orders: Order.pending.count,
        revenue: Order.where(status: [ "confirmed", "processing", "shipped", "delivered" ]).sum(:total_amount),
        recent_orders: Order.recent.limit(5).as_json(include: { user: { only: [ :name ] } })
      }

      render json: stats
    end

    private

    def set_order
      @order = Order.find_by(id: params[:id])
      unless @order
        render json: {
          success: false,
          error: "Order not found"
        }, status: :not_found
        return
      end
      unless current_user.admin? || @order.user == current_user
        render json: {
          success: false,
          error: "You are not authorized to access this order"
        }, status: :forbidden
        nil
      end
    end

    def order_params
      params.permit(
        :payment_method,
        shipping_address: [ :street, :city, :state, :zip_code, :country ]
      )
    end
  end
end
