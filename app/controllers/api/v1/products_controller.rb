module Api::V1
  class ProductsController < ApplicationController
    # before_action :set_product, only: [:show, :update, :destroy]
    # skip_before_action :authenticate_user, only: [:index, :show]

    # GET /api/v1/products
    def index
      @products = Product.includes(:category)
      
      # Apply all filters
      @products = apply_filters(@products)
      
      # Apply sorting
      @products = apply_sorting(@products)
      
      # Pagination
      @products = @products.page(params[:page]).per(params[:limit] || 20)
      
      render json: {
        products: @products.as_json(include: :category, methods: [:final_price, :in_stock?]),
        pagination: {
          current_page: @products.current_page,
          total_pages: @products.total_pages,
          total_count: @products.total_count,
          per_page: @products.limit_value
        }
      }
    end

    # GET /api/v1/products/:id
    def show
      render json: @product.as_json(
        include: :category, 
        methods: [:final_price, :in_stock?, :available_colors]
      )
    end

    # POST /api/v1/products
    def create
      @product = Product.new(product_params)
      
      if @product.save
        render json: @product.as_json(include: :category), status: :created
      else
        render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/products/:id
    def update
      if @product.update(product_params)
        render json: @product.as_json(include: :category)
      else
        render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/products/:id
    def destroy
      @product.destroy
      head :no_content
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      put(:product)
      params.require(:product).permit(
        :name, :price, :discount, :quantity, :sold, :rating, :category_id,
        img: [], 
        specs: [:label, :value],
        specs_detail: [:label, :value],
        color: [:name, :code]
      )
    end

    def apply_filters(products)
      # Name search filter
      products = products.where('name ILIKE ?', "%#{params[:search]}%") if params[:search]

      # Category filter
      products = products.where(category_id: params[:category_id]) if params[:category_id]

      # In-stock filter
      products = products.where('quantity > 0') if params[:in_stock] == 'true'
      
      # Price range filter
      if params[:price_min].present? && params[:price_min].to_f >= 0
        products = products.where('price >= ?', params[:price_min].to_f)
      end
      
      if params[:price_max].present? && params[:price_max].to_f >= 0
        products = products.where('price <= ?', params[:price_max].to_f)
      end
      
      # Discount filter
      products = products.where('discount > 0') if params[:discount] == 'true'
      
      # Advanced specs filtering
      products = filter_by_specs(products)
      
      products
    end

    def filter_by_specs(products)
      # Brand filter
      if params[:brands].present?
        puts "Filtering by brands: #{params[:brands]}"
        brand_values = params[:brands].split(',')
        brand_conditions = brand_values.map { |brand| "specs::text ILIKE ?" }
        brand_params = brand_values.map { |brand| "%\"value\": \"#{brand}\"%" }
        puts "Brand conditions: #{brand_conditions}"
        puts "Brand params: #{brand_params}"
        products = products.where(brand_conditions.join(' OR '), *brand_params)
      end

      # RAM filter
      if params[:ram].present?
        ram_values = params[:ram].split(',')
        ram_conditions = ram_values.map { |ram| "specs::text ILIKE ?" }
        ram_params = ram_values.map { |ram| "%\"value\": \"%#{ram}%\"%" }
        products = products.where(ram_conditions.join(' OR '), *ram_params)
      end
      
      # Screen size filter
      if params[:screen_size].present?
        screen_sizes = params[:screen_size].split(',')
        screen_conditions = screen_sizes.map { |size| "specs::text ILIKE ?" }
        screen_params = screen_sizes.map { |size| "%\"value\": \"%#{size}%\"%" }
        products = products.where(screen_conditions.join(' OR '), *screen_params)
      end
      
      # Processor filter
      if params[:processor].present?
        processors = params[:processor].split(',')
        processor_conditions = processors.map { |proc| "specs::text ILIKE ?" }
        processor_params = processors.map { |proc| "%\"value\": \"%#{proc}%\"%" }
        products = products.where(processor_conditions.join(' OR '), *processor_params)
      end
      
      # GPU Brand filter
      if params[:gpu_brand].present?
        gpu_brands = params[:gpu_brand].split(',')
        gpu_conditions = gpu_brands.map { |gpu| "specs::text ILIKE ?" }
        gpu_params = gpu_brands.map { |gpu| "%\"value\": \"%#{gpu}%\"%" }
        products = products.where(gpu_conditions.join(' OR '), *gpu_params)
      end
      
      # Drive size filter
      if params[:drive_size].present?
        drive_sizes = params[:drive_size].split(',')
        drive_conditions = drive_sizes.map { |drive| "specs::text ILIKE ?" }
        drive_params = drive_sizes.map { |drive| "%\"value\": \"%#{drive}%\"%" }
        products = products.where(drive_conditions.join(' OR '), *drive_params)
      end
      
      products
    end

    def apply_sorting(products)
      case params[:sort]
      when 'price_asc'
        products.order(price: :asc)
      when 'price_desc'
        products.order(price: :desc)
      when 'featured'
        products.order(sold: :desc, rating: :desc)
      when 'rating'
        products.order(rating: :desc)
      when 'newest'
        products.order(created_at: :desc)
      when 'popular'
        products.order(sold: :desc)
      else
        products.order(created_at: :desc)
      end
    end
  end
end