module Api::V1
  class ReviewsController < ApplicationController
    skip_before_action :authenticate_user, only: [ :index ]
    before_action :set_product, only: [ :index, :create, :update, :destroy ]

    # GET /api/v1/products/:product_id/reviews
    def index
      @reviews = @product.reviews.includes(:user).recent
      @reviews = @reviews.page(params[:page]).per(params[:limit] || 10)
      render json: {
        reviews: @reviews.as_json(include: { user: { only: [:id, :name] } }),
        pagination: {
          current_page: @reviews.current_page,
          total_pages: @reviews.total_pages,
          total_count: @reviews.total_count
        },
        summary: {
          average_rating: @product.rating,
          total_reviews: @product.number_of_rating,
          # rating_distribution: @product.rating_distribution
        }
      }
    end

    # POST /api/v1/products/:product_id/reviews
    def create
      # Check if user already reviewed this product
      existing_review = @product.reviews.find_by(user: current_user)
      
      if existing_review
        render json: {
          success: false,
          error: "You have already reviewed this product"
        }, status: :unprocessable_entity
        return
      end
      
      @review = @product.reviews.new(review_params)
      @review.user = current_user
      
      if @review.save
        render json: {
          success: true,
          message: "Review created successfully",
          review: @review.as_json(include: { user: { only: [:id, :name] } }),
          product_summary: {
            average_rating: @product.rating,
            total_reviews: @product.number_of_rating
          }
        }, status: :created
      else
        render json: {
          success: false,
          errors: @review.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    # PATCH /api/v1/products/:product_id/reviews/:id
    def update
      # Only allow user to update their own review
      if @review.user != current_user
        render json: {
          success: false,
          error: "You can only update your own reviews"
        }, status: :forbidden
        return
      end
      
      if @review.update(review_params)
        render json: {
          success: true,
          message: "Review updated successfully",
          review: @review.as_json(include: { user: { only: [:id, :name] } }),
          product_summary: {
            average_rating: @product.rating,
            total_reviews: @product.number_of_rating
          }
        }
      else
        render json: {
          success: false,
          errors: @review.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    def destroy
    end

    private
    
    def set_product
      @product = Product.find(params[:product_id])
    end
    
    def set_review
      @review = Review.find(params[:id])
    end
    
    def review_params
      params.require(:review).permit(:rating, :comment)
    end
  end
end
