module Api::V1
  class ProductsController < ApplicationController
    skip_before_action :authenticate_user, only: [ :index, :show ]

    before_action :require_admin, only: [ :create, :update, :destroy ]
    before_action :require_customer, only: [ :add_sales, :add_rating ]

    # GET /api/v1/products
    def index
      @products = Product.includes(:category, :sub_category)
      @products = apply_filters(@products)
      @products = apply_sorting(@products)
      @products = @products.page(params[:page]).per(params[:limit] || 20)

      render(
        json: {
          products: @products.as_json(include: :category, methods: [ :final_price, :in_stock? ]),
          pagination: {
            current_page: @products.current_page,
            total_pages: @products.total_pages,
            total_count: @products.total_count,
            per_page: @products.limit_value
          }
        }
      )
    end

    # GET /api/v1/products/:id
    def show
      @product = Product.find(params[:id])

      render(
        json: @product.as_json(
          methods: [ :final_price, :in_stock?, :available_colors ]
        )
      )
    end

    # POST /api/v1/products
    def create
      @product = Product.new(product_params)

      if @product.save
        # puts "params", params[:specs_detail]
        # params[:specs_detail].each { |value|
        #   ProductSpec.add_value_to_label(value[:label], value[:value])
        #   # puts "value is: ", value[:label]
        # }
        render(json: @product.as_json(include: [ :category, :sub_category ]), status: :created)
      else
        render(json: { errors: @product.errors.full_messages }, status: :unprocessable_entity)
      end
    end

    # PATCH /api/v1/products/:id
    def update
      @product = Product.find(params[:id])

      if @product.update(product_params)
        render(json: @product.as_json(include: [ :category, :sub_category ]))
      else
        render(json: { errors: @product.errors.full_messages }, status: :unprocessable_entity)
      end
    end

    # PATCH /api/v1/products/:id/add_sales
    def add_sales
      @product = Product.find(params[:id])

      amount = params[:amount].to_i
      color_name = params[:color_name]

      puts(params[:id], params[:amount], params[:color_name])

      result = @product.add_sales(color_name, amount)

      if result
        render(
          json: {
            success: true,
            message: "Sales added successfully",
            product: @product.as_json(
              include: [ :category, :sub_category ],
              methods: [ :final_price, :in_stock?, :available_colors ]
            )
          }
        )
      else
        render(
          json: {
            success: false,
            error: "Failed to add sales. Check stock availability."
          },
          status: :unprocessable_entity
        )
      end
    end

    # PATCH /api/v1/products/:id/add_rating
    def add_rating
      @product = Product.find(params[:id])

      new_rating = params[:rating].to_f

      if @product.add_rating(new_rating)
        render(
          json: {
            success: true,
            message: "Rating added successfully",
            product: @product.as_json(only: [ :id, :rating, :number_of_ratings ])
          }
        )
      else
        render(
          json: {
            success: false,
            error: "Rating must be between 1 and 5"
          },
          status: :unprocessable_entity
        )
      end
    end

    # DELETE /api/v1/products/:id
    def destroy
      # @product.destroy
      # head :no_content
    end

    private

    def product_params
      params.require(:product).permit(
        :name,
        :price,
        :discount,
        :quantity,
        :sold,
        :rating,
        :category_id,
        :sub_category_id,
        img: [],
        specs: [ :label, :value ],
        specs_detail: [ :label, :value ],
        color: [ :name, :code, :quantity ]
      )
    end

    def apply_filters(products)
      # Name search filter
      products = products.where("name ILIKE ?", "%#{params[:search]}%") if params[:search]

      # Category filter
      products = products.where(category_id: params[:category_id]) if params[:category_id]

      # Sub Category filter
      products = products.where(sub_category_id: params[:sub_category_id]) if params[:sub_category_id]

      # In-stock filter
      products = products.where("quantity > 0") if params[:in_stock] == "true"

      # Price range filter
      if params[:price_min].present? && params[:price_min].to_f >= 0
        products = products.where("price >= ?", params[:price_min].to_f)
      end

      if params[:price_max].present? && params[:price_max].to_f >= 0
        products = products.where("price <= ?", params[:price_max].to_f)
      end

      # Discount filter
      products = products.where("discount > 0") if params[:discount] == "true"

      # Advanced specs filtering
      products = filter_by_specs(products)

      products
    end

    def filter_by_specs(products)
      # Brand filter
      if params[:brands].present?
        brand_values = params[:brands].split(",")
        brand_conditions = brand_values.map { |brand| "specs::text ILIKE ?" }
        brand_params = brand_values.map { |brand| "%\"value\": \"#{brand}\"%" }
        products = products.where(brand_conditions.join(" OR "), *brand_params)
      end

      # RAM filter
      if params[:ram].present?
        ram_values = params[:ram].split(",")
        ram_conditions = ram_values.map { |ram| "specs::text ILIKE ?" }
        ram_params = ram_values.map { |ram| "%\"value\": \"%#{ram}%\"%" }
        products = products.where(ram_conditions.join(" OR "), *ram_params)
      end

      # Screen size filter
      if params[:screen_size].present?
        screen_sizes = params[:screen_size].split(",")
        screen_conditions = screen_sizes.map { |size| "specs::text ILIKE ?" }
        screen_params = screen_sizes.map { |size| "%\"value\": \"%#{size}%\"%" }
        products = products.where(screen_conditions.join(" OR "), *screen_params)
      end

      # Processor filter
      if params[:processor].present?
        processors = params[:processor].split(",")
        processor_conditions = processors.map { |proc| "specs::text ILIKE ?" }
        processor_params = processors.map { |proc| "%\"value\": \"%#{proc}%\"%" }
        products = products.where(processor_conditions.join(" OR "), *processor_params)
      end

      # GPU Brand filter
      if params[:gpu_brand].present?
        gpu_brands = params[:gpu_brand].split(",")
        gpu_conditions = gpu_brands.map { |gpu| "specs::text ILIKE ?" }
        gpu_params = gpu_brands.map { |gpu| "%\"value\": \"%#{gpu}%\"%" }
        products = products.where(gpu_conditions.join(" OR "), *gpu_params)
      end

      # Drive size filter
      if params[:drive_size].present?
        drive_sizes = params[:drive_size].split(",")
        drive_conditions = drive_sizes.map { |drive| "specs::text ILIKE ?" }
        drive_params = drive_sizes.map { |drive| "%\"value\": \"%#{drive}%\"%" }
        products = products.where(drive_conditions.join(" OR "), *drive_params)
      end

      products
    end

    def apply_sorting(products)
      puts "Sorting param: #{params[:sort]}"
      case params[:sort]
      when "price-asc"
        puts "Sorting by price ascending"
        products.order(price: :asc)
      when "price-desc"
        puts "Sorting by price ascending"
        products.order(price: :desc)
      when "featured"
        products.order(sold: :desc, rating: :desc)
      when "rating"
        products.order(rating: :desc)
      when "newest"
        products.order(created_at: :desc)
      when "popular"
        products.order(sold: :desc)
      else
        products.order(created_at: :desc)
      end
    end
  end
end
