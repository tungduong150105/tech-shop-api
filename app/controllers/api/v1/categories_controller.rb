module Api::V1
  class CategoriesController < ApplicationController
    skip_before_action :authenticate_user, only: [ :index, :show ]
    before_action :require_admin, only: [ :create, :update, :destroy ]
    before_action :set_category, only: [ :show, :update, :destroy ]

    # GET /api/v1/categories
    def index
      @categories = Category.all
      render json: @categories, include: [ :sub_categories ]
    end

    # GET /api/v1/categories/:id
    def show
      render json: @category.as_json(include: :products), include: [ :sub_categories ]
    end

    # POST /api/v1/categories
    def create
      @category = Category.new(category_params)
      if @category.save
        render json: @category, status: :created
      else
        render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/categories/:id
    def update
      if @category.update(category_params)
        render json: @category, status: :ok
      else
        render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/categories/:id
    def destroy
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :image_url, :description)
    end
  end
end
