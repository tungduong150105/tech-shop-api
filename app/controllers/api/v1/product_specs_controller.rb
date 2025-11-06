module Api::V1
  class ProductSpecsController < ApplicationController
    skip_before_action :authenticate_user, only: [ :index ]

    def index
      @product_specs = ProductSpec.all

      if params[:category_id]
        @product_specs = @product_specs.where(category_id: params[:category_id])
      end

      render(json: @product_specs.as_json(except: [ :id, :created_at, :updated_at ]))
    end
  end
end
