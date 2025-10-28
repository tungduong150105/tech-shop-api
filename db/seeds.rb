# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Product.destroy_all
Category.destroy_all

categories = [
  { 
    name: 'Laptops', 
    image_url: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500&h=300&fit=crop',
    description: 'High-performance laptops for work and gaming' 
  },
  { 
    name: 'Smartphones', 
    image_url: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500&h=300&fit=crop',
    description: 'Latest smartphones and accessories' 
  },
  { 
    name: 'Tablets', 
    image_url: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500&h=300&fit=crop',
    description: 'Tablets for productivity and entertainment' 
  },
  { 
    name: 'Accessories', 
    image_url: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&h=300&fit=crop',
    description: 'Chargers, cases, and other accessories' 
  },
  { 
    name: 'Gaming', 
    image_url: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=500&h=300&fit=crop',
    description: 'Gaming consoles and accessories' 
  },
  { 
    name: 'Audio', 
    image_url: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&h=300&fit=crop',
    description: 'Headphones, speakers, and audio equipment' 
  }
]

categories.each do |cat_data|
  Category.create!(cat_data)
  puts "Created category: #{cat_data[:name]}"
end

laptops_category = Category.find_by(name: 'Laptops')
smartphones_category = Category.find_by(name: 'Smartphones')

products = [
  {
    name: "MacBook Pro 16-inch",
    price: 2399.99,
    discount: 10.0,
    quantity: 50,
    sold: 125,
    rating: 4.8,
    category_id: laptops_category.id,
    img: [
      "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&h=600&fit=crop",
      "https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=800&h=600&fit=crop"
    ],
    specs: [
      { label: "Brand", value: "Apple" },
      { label: "Processor", value: "Apple M1 Pro" },
      { label: "RAM", value: "16GB" },
      { label: "Storage", value: "1TB SSD" },
      { label: "Display", value: "16.2-inch" },
      { label: "GPU", value: "16-core GPU" }
    ],
    specs_detail: [
      { label: "Chip", value: "Apple M1 Pro chip" },
      { label: "CPU", value: "10-core CPU" },
      { label: "Memory Type", value: "Unified Memory" }
    ],
    color: [
      { name: "Space Gray", code: "#535653" },
      { name: "Silver", code: "#E8E8E8" }
    ]
  },
  {
    name: "Dell XPS 13",
    price: 1299.99,
    discount: 5.0,
    quantity: 30,
    sold: 80,
    rating: 4.5,
    category_id: laptops_category.id,
    img: [
      "https://images.unsplash.com/photo-1593640408182-31c70c8268f5?w=800&h=600&fit=crop"
    ],
    specs: [
      { label: "Brand", value: "Dell" },
      { label: "Processor", value: "Intel Core i7" },
      { label: "RAM", value: "16GB" },
      { label: "Storage", value: "512GB SSD" },
      { label: "Display", value: "13.4-inch" },
      { label: "GPU", value: "Intel Iris Xe" }
    ],
    color: [
      { name: "Platinum", code: "#C0C0C0" }
    ]
  },
  {
    name: "Asus ROG Zephyrus",
    price: 1899.99,
    discount: 15.0,
    quantity: 25,
    sold: 60,
    rating: 4.6,
    category_id: laptops_category.id,
    img: [
      "https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=800&h=600&fit=crop"
    ],
    specs: [
      { label: "Brand", value: "Asus" },
      { label: "Processor", value: "AMD Ryzen 7" },
      { label: "RAM", value: "32GB" },
      { label: "Storage", value: "1TB SSD" },
      { label: "Display", value: "15.6-inch" },
      { label: "GPU", value: "NVIDIA RTX 4060" }
    ],
    color: [
      { name: "Black", code: "#000000" }
    ]
  }
]

products.each do |product_data|
  Product.create!(product_data)
  puts "Created product: #{product_data[:name]}"
end
