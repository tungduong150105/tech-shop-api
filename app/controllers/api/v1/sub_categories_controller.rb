module Api::V1
  class SubCategoriesController < ApplicationController
    before_action :set_sub_category, only: [ :show, :update, :destroy ]
    before_action :require_admin, only: [ :create, :update, :destroy ]

    # GET /api/v1/sub_categories
    def index
      if params[:category_id]
        @sub_categories = Category.find(params[:category_id]).sub_categories
      else
        @sub_categories = SubCategory.all
      end
      render json: @sub_categories
    end

    # GET /api/v1/sub_categories/:id
    def show
      render json: @sub_category, include: [ :category ]
    end

    # POST /api/v1/sub_categories
    def create
      @sub_category = SubCategory.new(sub_category_params)

      if @sub_category.save
        render json: @sub_category, status: :created
      else
        render json: @sub_category.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/sub_categories/:id
    def update
      if @sub_category.update(sub_category_params)
        render json: @sub_category
      else
        render json: @sub_category.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/sub_categories/:id
    def destroy
    end

    private

    def set_sub_category
      @sub_category = SubCategory.find(params[:id])
    end

    def sub_category_params
      params.require(:sub_category).permit(:name, :image_url, :description, :category_id)
    end
  end
end
