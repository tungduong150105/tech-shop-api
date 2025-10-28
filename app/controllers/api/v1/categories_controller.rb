module Api::V1
  class CategoriesController < ApplicationController
    # before_action :authenticate_user, only: [:index, :show]

    # GET /api/v1/categories
    def index
      @categories = Category.all
      render json: @categories, status: :ok
    end

    # GET /api/v1/categories/:id
    def show
      @category = Category.find(params[:id])
      render json: @category.as_json(include: :products)
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

    #PATCH/PUT /api/v1/categories/:id
    def update
      @category = Category.find(params[:id])
      if @category.update(category_params)
        render json: @category, status: :ok
      else
        render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/categories/:id
    def destroy
      @category = Category.find(params[:id])
      @category.destroy
      head :no_content
    end

    private

    def category_params
      params.require(:category).permit(:name, :image_url, :description)
    end
  end
end