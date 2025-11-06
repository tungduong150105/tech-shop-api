OrderItem.destroy_all
Order.destroy_all
Review.destroy_all
CartItem.destroy_all
Cart.destroy_all
Product.destroy_all
User.destroy_all
SubCategory.destroy_all
Category.destroy_all
ProductSpec.destroy_all

puts "🗑️  Clearing all data..."

# Create admin user
admin = User.create!(
  name: 'Admin User',
  email: 'admin@techshop.com',
  password: 'password',
  role: 'admin',
  phone: '+1234567890',
  address: '123 Admin Street, Tech City'
)
puts "✅ Created admin: #{admin.email}"

# Create sample customers
customers = []
5.times do |i|
  customer = User.create!(
    name: "Customer #{i + 1}",
    email: "customer#{i + 1}@example.com",
    password: 'password',
    role: 'customer',
    phone: "+123456789#{i}",
    address: "#{i + 100} Customer Street, City #{i + 1}"
  )
  customers << customer
  puts "✅ Created customer: #{customer.email}"
end

# Create main categories
categories_data = [
  { name: 'Mobile', image_url: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500&h=300&fit=crop', description: 'Smartphones and mobile devices' },
  { name: 'Laptop', image_url: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500&h=300&fit=crop', description: 'Laptop computers and notebooks' },
  { name: 'Tablet', image_url: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500&h=300&fit=crop', description: 'Tablets and iPads' },
  { name: 'Audio', image_url: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&h=300&fit=crop', description: 'Audio equipment and accessories' },
  { name: 'Wearable', image_url: 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=500&h=300&fit=crop', description: 'Wearable technology and smart devices' },
  { name: 'Camera', image_url: 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=500&h=300&fit=crop', description: 'Cameras and photography equipment' },
  { name: 'Gaming', image_url: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=500&h=300&fit=crop', description: 'Gaming consoles and accessories' },
  { name: 'Network', image_url: 'https://images.unsplash.com/photo-1563013541-5a61d32754f5?w=500&h=300&fit=crop', description: 'Networking equipment and routers' },
  { name: 'Accessories', image_url: 'https://images.unsplash.com/photo-1556656793-08538906a9f8?w=500&h=300&fit=crop', description: 'Tech accessories and peripherals' }
]

categories = {}
categories_data.each do |cat_data|
  category = Category.create!(cat_data)
  categories[cat_data[:name].downcase] = category
  puts "✅ Created main category: #{category.name}"
end

# Auto-generate sub-categories
sub_categories_mapping = {
  'mobile' => ['Smartphones', 'Feature Phones', 'Mobile Accessories'],
  'laptop' => ['Gaming Laptops', 'Business Laptops', 'Ultrabooks', '2-in-1 Laptops'],
  'tablet' => ['Android Tablets', 'iPad', 'Windows Tablets'],
  'audio' => ['Headphones', 'Earbuds', 'Speakers', 'Soundbars'],
  'wearable' => ['Smartwatches', 'Fitness Trackers', 'VR Headsets'],
  'camera' => ['DSLR Cameras', 'Mirrorless Cameras', 'Action Cameras'],
  'gaming' => ['Gaming Consoles', 'Gaming PCs', 'Gaming Accessories'],
  'network' => ['WiFi Routers', 'Network Switches', 'Modems'],
  'accessories' => ['Phone Cases', 'Chargers', 'Power Banks', 'Cables']
}

sub_categories = {}
sub_categories_mapping.each do |category_name, sub_cat_names|
  category = categories[category_name]
  sub_cat_names.each do |sub_cat_name|
    sub_category = SubCategory.create!(
      name: sub_cat_name,
      image_url: categories_data.find { |c| c[:name].downcase == category_name }[:image_url],
      category_id: category.id
    )
    sub_categories[sub_cat_name.downcase.gsub(' ', '_').gsub('-', '_')] = sub_category
    puts "✅ Created sub-category: #{sub_category.name}"
  end
end

# ========== REAL PRODUCTS DATA ==========
products_data = [
  # ========== MOBILE - SMARTPHONES ==========
  {
    name: "iPhone 15 Pro",
    price: 999.99,
    discount: 0.0,
    quantity: 100,
    sold: 256,
    category_id: categories['mobile'].id,
    sub_category_id: sub_categories['smartphones'].id,
    img: ["https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=800&h=600&fit=crop"],
    specs: [
      { label: "brand", value: "Apple" },
      { label: "ram", value: "8GB" },
      { label: "screen_size", value: "6.1 inch" },
      { label: "processor", value: "Apple A17 Pro" },
      { label: "gpu_brand", value: "Apple" },
      { label: "drive_size", value: "128GB" }
    ],
    specs_detail: [
      { label: "Display", value: "6.1-inch Super Retina XDR, 2556x1179" },
      { label: "Chip", value: "A17 Pro (6-core CPU, 6-core GPU)" },
      { label: "Storage", value: "128GB NVMe" },
      { label: "Camera", value: "48MP Main, 12MP Ultra Wide, 12MP Telephoto" },
      { label: "Battery", value: "Up to 23 hours video playback" },
      { label: "Connectivity", value: "5G, Wi-Fi 6E, Bluetooth 5.3" },
      { label: "Weight", value: "187 g" }
    ],
    color: [
      { "name" => "Natural Titanium", "code" => "#8F8F8F", "quantity" => 40 },
      { "name" => "Blue Titanium", "code" => "#4A6FA5", "quantity" => 30 },
      { "name" => "White Titanium", "code" => "#F5F5F7", "quantity" => 30 }
    ]
  },
  {
    name: "Samsung Galaxy S24 Ultra",
    price: 1199.99,
    discount: 5.0,
    quantity: 80,
    sold: 189,
    category_id: categories['mobile'].id,
    sub_category_id: sub_categories['smartphones'].id,
    img: ["https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800&h=600&fit=crop"],
    specs: [
      { label: "brand", value: "Samsung" },
      { label: "ram", value: "12GB" },
      { label: "screen_size", value: "6.8 inch" },
      { label: "processor", value: "Snapdragon 8 Gen 3" },
      { label: "gpu_brand", value: "Qualcomm" },
      { label: "drive_size", value: "256GB" }
    ],
    specs_detail: [
      { label: "Display", value: "6.8-inch Dynamic AMOLED 2X, 3088x1440" },
      { label: "Chip", value: "Snapdragon 8 Gen 3" },
      { label: "Storage", value: "256GB UFS 4.0" },
      { label: "Camera", value: "200MP Main, 12MP Ultra Wide, 50MP Telephoto" },
      { label: "Battery", value: "5000mAh, Up to 26 hours" },
      { label: "Connectivity", value: "5G, Wi-Fi 7, Bluetooth 5.3" },
      { label: "Weight", value: "232 g" }
    ],
    color: [
      { "name" => "Titanium Black", "code" => "#2D2D2D", "quantity" => 30 },
      { "name" => "Titanium Gray", "code" => "#8E8E93", "quantity" => 25 },
      { "name" => "Titanium Violet", "code" => "#8B5FBF", "quantity" => 25 }
    ]
  },
  {
    name: "Google Pixel 8 Pro",
    price: 899.99,
    discount: 10.0,
    quantity: 60,
    sold: 134,
    category_id: categories['mobile'].id,
    sub_category_id: sub_categories['smartphones'].id,
    img: ["https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=800&h=600&fit=crop"],
    specs: [
      { label: "brand", value: "Google" },
      { label: "ram", value: "12GB" },
      { label: "screen_size", value: "6.7 inch" },
      { label: "processor", value: "Google Tensor G3" },
      { label: "gpu_brand", value: "Google" },
      { label: "drive_size", value: "128GB" }
    ],
    specs_detail: [
      { label: "Display", value: "6.7-inch LTPO OLED, 2992x1344" },
      { label: "Chip", value: "Google Tensor G3" },
      { label: "Storage", value: "128GB UFS 3.1" },
      { label: "Camera", value: "50MP Main, 48MP Ultra Wide, 48MP Telephoto" },
      { label: "Battery", value: "5050mAh, Up to 24 hours" },
      { label: "Connectivity", value: "5G, Wi-Fi 7, Bluetooth 5.3" },
      { label: "Weight", value: "213 g" }
    ],
    color: [
      { "name" => "Obsidian", "code" => "#1A1A1A", "quantity" => 25 },
      { "name" => "Porcelain", "code" => "#F5F5F5", "quantity" => 20 },
      { "name" => "Bay", "code" => "#4A6FA5", "quantity" => 15 }
    ]
  },
  {
    name: "iPhone 14",
    price: 699.99,
    discount: 15.0,
    quantity: 120,
    sold: 320,
    category_id: categories['mobile'].id,
    sub_category_id: sub_categories['smartphones'].id,
    img: ["https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=800&h=600&fit=crop"],
    specs: [
      { label: "brand", value: "Apple" },
      { label: "ram", value: "6GB" },
      { label: "screen_size", value: "6.1 inch" },
      { label: "processor", value: "Apple A15 Bionic" },
      { label: "gpu_brand", value: "Apple" },
      { label: "drive_size", value: "128GB" }
    ],
    specs_detail: [
      { label: "Display", value: "6.1-inch Super Retina XDR" },
      { label: "Chip", value: "A15 Bionic" },
      { label: "Storage", value: "128GB" },
      { label: "Camera", value: "12MP Dual Camera System" },
      { label: "Battery", value: "Up to 20 hours video playback" },
      { label: "Connectivity", value: "5G, Wi-Fi 6, Bluetooth 5.3" },
      { label: "Weight", value: "172 g" }
    ],
    color: [
      { "name" => "Midnight", "code" => "#191E2A", "quantity" => 50 },
      { "name" => "Starlight", "code" => "#F5F5F7", "quantity" => 40 },
      { "name" => "Blue", "code" => "#4A6FA5", "quantity" => 30 }
    ]
  },

  # ========== LAPTOP ==========
  {
    name: "MacBook Pro 16-inch M3",
    price: 2399.99,
    discount: 10.0,
    quantity: 50,
    sold: 125,
    category_id: categories['laptop'].id,
    sub_category_id: sub_categories['gaming_laptops'].id,
    img: ["https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&h=600&fit=crop"],
    specs: [
      { label: "brand", value: "Apple" },
      { label: "ram", value: "16GB" },
      { label: "screen_size", value: "16 inch" },
      { label: "processor", value: "Apple M3 Pro" },
      { label: "gpu_brand", value: "Apple" },
      { label: "drive_size", value: "512GB" }
    ],
    specs_detail: [
      { label: "Processor", value: "Apple M3 Pro (12-core CPU, 18-core GPU)" },
      { label: "Memory", value: "16GB Unified Memory" },
      { label: "Storage", value: "512GB SSD" },
      { label: "Display", value: "16.2-inch Liquid Retina XDR, 3456x2234" },
      { label: "Battery", value: "Up to 22 hours" },
      { label: "Ports", value: "3x Thunderbolt 4, HDMI, SDXC, MagSafe 3" },
      { label: "Weight", value: "2.15 kg" }
    ],
    color: [
      { "name" => "Space Gray", "code" => "#535653", "quantity" => 30 },
      { "name" => "Silver", "code" => "#C0C0C0", "quantity" => 20 }
    ]
  },
  {
    name: "Dell XPS 15",
    price: 1899.99,
    discount: 15.0,
    quantity: 35,
    sold: 89,
    category_id: categories['laptop'].id,
    sub_category_id: sub_categories['business_laptops'].id,
    img: ["https://images.unsplash.com/photo-1593640408182-31c70c8268f5?w=800&h=600&fit=crop"],
    specs: [
      { label: "brand", value: "Dell" },
      { label: "ram", value: "32GB" },
      { label: "screen_size", value: "15 inch" },
      { label: "processor", value: "Intel Core i7" },
      { label: "gpu_brand", value: "NVIDIA" },
      { label: "drive_size", value: "1TB" }
    ],
    specs_detail: [
      { label: "Processor", value: "Intel Core i7-13700H (14 cores)" },
      { label: "Memory", value: "32GB DDR5" },
      { label: "Storage", value: "1TB NVMe SSD" },
      { label: "Display", value: "15.6-inch 4K UHD+ Touchscreen" },
      { label: "Graphics", value: "NVIDIA GeForce RTX 4060" },
      { label: "Battery", value: "Up to 10 hours" },
      { label: "Weight", value: "1.83 kg" }
    ],
    color: [
      { "name" => "Platinum Silver", "code" => "#C0C0C0", "quantity" => 20 },
      { "name" => "Frost White", "code" => "#F5F5F5", "quantity" => 15 }
    ]
  },

  # ========== AUDIO ==========
  {
    name: "Sony WH-1000XM5",
    price: 399.99,
    discount: 15.0,
    quantity: 120,
    sold: 450,
    category_id: categories['audio'].id,
    sub_category_id: sub_categories['headphones'].id,
    img: ["https://images.unsplash.com/photo-1583394838336-acd977736f90?w=800&h=600&fit=crop"],
    specs: [
      { label: "brand", value: "Sony" },
      { label: "type", value: "Wireless" },
      { label: "battery", value: "30 hours" },
      { label: "noise_canceling", value: "Yes" }
    ],
    specs_detail: [
      { label: "Type", value: "Wireless Over-Ear" },
      { label: "Battery Life", value: "Up to 30 hours" },
      { label: "Noise Canceling", value: "Industry-leading ANC" },
      { label: "Driver", value: "30mm Dynamic Driver" },
      { label: "Connectivity", value: "Bluetooth 5.2, NFC" },
      { label: "Weight", value: "250g" },
      { label: "Features", value: "Touch Controls, Voice Assistant" }
    ],
    color: [
      { "name" => "Black", "code" => "#000000", "quantity" => 80 },
      { "name" => "Silver", "code" => "#C0C0C0", "quantity" => 40 }
    ]
  },
  {
    name: "Apple AirPods Pro 2",
    price: 249.99,
    discount: 5.0,
    quantity: 200,
    sold: 600,
    category_id: categories['audio'].id,
    sub_category_id: sub_categories['earbuds'].id,
    img: ["https://images.unsplash.com/photo-1590658165737-15a047b8b5e0?w=800&h=600&fit=crop"],
    specs: [
      { label: "brand", value: "Apple" },
      { label: "type", value: "Wireless" },
      { label: "battery", value: "6 hours" },
      { label: "noise_canceling", value: "Active" }
    ],
    specs_detail: [
      { label: "Type", value: "True Wireless Earbuds" },
      { label: "Battery Life", value: "6 hours (with ANC), 30 hours with case" },
      { label: "Noise Canceling", value: "Active Noise Cancellation" },
      { label: "Chip", value: "H2" },
      { label: "Connectivity", value: "Bluetooth 5.3" },
      { label: "Water Resistance", value: "IPX4" },
      { label: "Features", value: "Spatial Audio, Transparency Mode" }
    ],
    color: [
      { "name" => "White", "code" => "#FFFFFF", "quantity" => 120 },
      { "name" => "Black", "code" => "#000000", "quantity" => 80 }
    ]
  },

  # ========== ACCESSORIES ==========
  {
    name: "Anker PowerCore 26800mAh",
    price: 79.99,
    discount: 15.0,
    quantity: 200,
    sold: 450,
    category_id: categories['accessories'].id,
    sub_category_id: sub_categories['power_banks'].id,
    img: ["https://images.unsplash.com/photo-1556656793-08538906a9f8?w=800&h=600&fit=crop"],
    specs: [
      { label: "brand", value: "Anker" },
      { label: "capacity", value: "26800mAh" },
      { label: "ports", value: "3 x USB-A" },
      { label: "fast_charging", value: "Yes" }
    ],
    specs_detail: [
      { label: "Capacity", value: "26800mAh" },
      { label: "Ports", value: "3 x USB-A, 1 x USB-C" },
      { label: "Input", value: "USB-C: 5V/3A" },
      { label: "Output", value: "Up to 30W total" },
      { label: "Weight", value: "558g" },
      { label: "Dimensions", value: "7.1 x 2.9 x 2.9 inches" },
      { label: "Features", value: "PowerIQ, VoltageBoost" }
    ],
    color: [
      { "name" => "Black", "code" => "#000000", "quantity" => 150 },
      { "name" => "Blue", "code" => "#1E3A5F", "quantity" => 50 }
    ]
  }
]

# Create all products
products = []
products_data.each_with_index do |product_data, index|
  product = Product.create!(product_data)
  products << product
  puts "✅ Created product #{index+1}: #{product.name}"
end

# Create sample reviews
puts "Creating sample reviews..."

sample_comments = [
  "Great product! Very satisfied with my purchase.",
  "Good quality and fast shipping.",
  "Exceeded my expectations. Would buy again!",
  "Decent product for the price.",
  "Amazing features and build quality.",
  "Works perfectly. No issues so far.",
  "Better than I expected. Highly recommend!",
  "Good value for money.",
  "Solid product. Does what it promises.",
  "Impressive performance and design."
]

products.each do |product|
  customers.shuffle.take(rand(3..8)).each do |user|
    Review.create!(
      user: user,
      product: product,
      rating: rand(4..5),
      comment: sample_comments.sample
    )
  end
end

puts "✅ Created #{Review.count} reviews"

# ========== CART DATA WITH COLORS ==========
puts "Creating sample cart data with colors..."

# Create carts for customers and add products with colors
customers.each_with_index do |customer, index|
  cart = customer.cart
  
  # Add different products with colors based on customer index
  case index
  when 0
    # Customer 1: Multiple iPhones in different colors
    iphone = products.find { |p| p.name == "iPhone 15 Pro" }
    cart.add_product(iphone, 1, { "name" => "Natural Titanium", "code" => "#8F8F8F" })
    cart.add_product(iphone, 1, { "name" => "Blue Titanium", "code" => "#4A6FA5" })
    
    airpods = products.find { |p| p.name == "Apple AirPods Pro 2" }
    cart.add_product(airpods, 2, { "name" => "White", "code" => "#FFFFFF" })
    
  when 1
    # Customer 2: Samsung phone and accessories
    samsung = products.find { |p| p.name == "Samsung Galaxy S24 Ultra" }
    cart.add_product(samsung, 1, { "name" => "Titanium Black", "code" => "#2D2D2D" })
    
    powerbank = products.find { |p| p.name == "Anker PowerCore 26800mAh" }
    cart.add_product(powerbank, 1, { "name" => "Black", "code" => "#000000" })
    
  when 2
    # Customer 3: Google Pixel and Sony headphones
    pixel = products.find { |p| p.name == "Google Pixel 8 Pro" }
    cart.add_product(pixel, 1, { "name" => "Obsidian", "code" => "#1A1A1A" })
    
    sony_headphones = products.find { |p| p.name == "Sony WH-1000XM5" }
    cart.add_product(sony_headphones, 1, { "name" => "Black", "code" => "#000000" })
    
  when 3
    # Customer 4: Laptop and iPhone
    macbook = products.find { |p| p.name == "MacBook Pro 16-inch M3" }
    cart.add_product(macbook, 1, { "name" => "Space Gray", "code" => "#535653" })
    
    iphone14 = products.find { |p| p.name == "iPhone 14" }
    cart.add_product(iphone14, 1, { "name" => "Midnight", "code" => "#191E2A" })
    
  when 4
    # Customer 5: Dell laptop and accessories
    dell = products.find { |p| p.name == "Dell XPS 15" }
    cart.add_product(dell, 1, { "name" => "Platinum Silver", "code" => "#C0C0C0" })
    
    airpods = products.find { |p| p.name == "Apple AirPods Pro 2" }
    cart.add_product(airpods, 1, { "name" => "Black", "code" => "#000000" })
  end
  
  puts "✅ Created cart for #{customer.name} with #{cart.cart_items.count} items"
end

puts "✅ Created #{Cart.count} carts"
puts "✅ Created #{CartItem.count} cart items"

# Display cart summary with colors
puts "\n🛒 Cart Data Overview:"
customers.each do |customer|
  cart = customer.cart
  if cart.cart_items.any?
    puts "  #{customer.name}: #{cart.total_items} items, Total: $#{cart.total_price}"
    cart.cart_items.each do |item|
      color_info = " (#{item.color['name']})"
      puts "    - #{item.quantity} x #{item.product.name}#{color_info} = $#{item.subtotal}"
    end
  else
    puts "  #{customer.name}: Empty cart"
  end
end

puts "🎉 Database seeded successfully!"
puts "📱 #{Category.count} main categories"
puts "📁 #{SubCategory.count} sub-categories"
puts "💻 #{Product.count} products"
puts "👥 #{User.count} users"
puts "⭐ #{Review.count} reviews"
puts "🛒 #{Cart.count} carts"
puts "📦 #{CartItem.count} cart items"

# Display summary
puts "\n📊 Sample Data Overview:"
Category.all.each do |category|
  puts "  #{category.name}: #{category.products.count} products"
end

# Display color usage in carts
puts "\n🎨 Color Usage in Carts:"
CartItem.all.each do |cart_item|
  puts "  #{cart_item.product.name}: #{cart_item.color['name']} (Qty: #{cart_item.quantity})"
end
