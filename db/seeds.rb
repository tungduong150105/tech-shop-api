# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
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
