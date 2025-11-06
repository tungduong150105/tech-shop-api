## Tech Shop API – v1

Base URL: `/api/v1`

- Authentication: Bearer token in `Authorization: Bearer <JWT>` unless noted.
- Content-Type: `application/json`
- Pagination: `page` (default 1), `limit` (varies; commonly 10 or 20). Responses include `pagination` when paginated.

### Auth

- POST `/auth/register`
  - Body: `{ "user": { "name": string, "email": string, "password": string, "phone"?: string, "address"?: string, "role"?: "admin"|"customer" } }`
  - 201: `{ success, message, user, token }`
- POST `/auth/login`
  - Body: `{ "email": string, "password": string }`
  - 200: `{ success, message, user, token }`
- GET `/auth/me`
  - Auth required
  - 200: `{ success, user }`
- PATCH `/auth/update_profile`
  - Auth required
  - Body: `{ "user": { "name"?: string, "phone"?: string, "address"?: string } }`
  - 200: `{ success, message, user }`
- POST `/auth/change_password`
  - Auth required
  - Body: `{ "current_password": string, "new_password": string }`
  - 200: `{ success, message }`

### Categories

- GET `/categories`
  - 200: `Category[]` (includes `sub_categories`)
- GET `/categories/:id`
  - 200: category with `products` (also includes `sub_categories`)
- POST `/categories`
  - Admin required
  - Body: `{ "category": { "name": string, "image_url": string, "description"?: string } }`
  - 201: `Category`
- PATCH `/categories/:id`
  - Admin required
  - Body: same as create (partial allowed)
  - 200: `Category`
- DELETE `/categories/:id`
  - Admin required
  - Note: endpoint present; deletion behavior not implemented yet

### Sub Categories

- GET `/sub_categories`
  - Query: `category_id` (optional to filter)
  - 200: `SubCategory[]`
- GET `/sub_categories/:id`
  - 200: `SubCategory` (includes `category`)
- POST `/sub_categories`
  - Admin required
  - Body: `{ "sub_category": { "name": string, "image_url": string, "description"?: string, "category_id": number } }`
  - 201: `SubCategory`
- PATCH `/sub_categories/:id`
  - Admin required
  - 200: `SubCategory`
- DELETE `/sub_categories/:id`
  - Admin required
  - Note: endpoint present; deletion behavior not implemented yet

### Products

- GET `/products`
  - Query filters:
    - `search` (ILIKE on `name`)
    - `category_id`, `sub_category_id`
    - `in_stock` = `true`
    - Price: `price_min`, `price_max`
    - `discount` = `true`
    - Specs (text search within `specs` JSON):
      - `brands=a,b`
      - `ram=8GB,16GB`
      - `screen_size=14,15.6`
      - `processor=i5,i7`
      - `gpu_brand=NVIDIA,AMD`
      - `drive_size=256GB,512GB`
    - Sorting `sort`: `price-asc` | `price-desc` | `featured` | `rating` | `newest` | `popular`
    - Pagination: `page`, `limit` (default 20)
  - 200: `{ products: Product[], pagination }`
- GET `/products/:id`
  - 200: `Product` (includes `final_price`, `in_stock?`, `available_colors`)
- POST `/products`
  - Admin required
  - Body: `{ "product": { "name": string, "price": number, "discount"?: number(0..100), "quantity"?: integer, "sold"?: integer, "rating"?: number, "category_id": number, "sub_category_id": number, "img"?: string[], "specs"?: [{"label": string, "value": any}] , "specs_detail"?: [{"label": string, "value": any}], "color"?: [{"name": string, "code": string, "quantity": integer}] } }`
  - 201: `Product` (includes `category`, `sub_category`)
- PATCH `/products/:id`
  - Admin required
  - Body: same as create (partial allowed)
  - 200: `Product`
- DELETE `/products/:id`
  - Admin required
  - Note: endpoint present; deletion behavior not implemented yet
- PATCH `/products/:id/add_sales`
  - Intended for customers (role check currently not enforced)
  - Body: `{ "amount": integer>0, "color_name": string }`
  - 200: `{ success, message, product }` or 422 on insufficient stock
- PATCH `/products/:id/add_rating`
  - Intended for customers (role check currently not enforced)
  - Body: `{ "rating": number }`
  - 200: `{ success, message, product: { id, rating, number_of_ratings } }`

### Reviews

- GET `/products/:product_id/reviews`
  - Public
  - Pagination: `page`, `limit` (default 10)
  - 200: `{ reviews: Review[], pagination, summary: { average_rating, total_reviews } }`
- POST `/products/:product_id/reviews`
  - Auth required
  - Body: `{ "review": { "rating": 1..5, "comment"?: string } }`
  - 201: `{ success, message, review, product_summary }`
- PATCH `/products/:product_id/reviews/:id`
  - Auth required (user can update own review)
  - Body: same as create
  - 200: `{ success, message, review, product_summary }`
- DELETE `/reviews/:id`
  - Auth required
  - Note: route exists; controller action not implemented yet

### Product Specs (filters metadata)

- GET `/filter`
  - Public
  - Query: `category_id` (optional)
  - 200: `ProductSpec[]` (without id/timestamps)

### Cart

Resource is a singleton bound to the authenticated user.

- GET `/cart`
  - 200: `{ cart: { id, total_items, total_price, total_original_price, total_discount, items: CartItem[] } }`
- POST `/cart/add_item/:product_id`
  - Body: `{ "quantity"?: integer>=1, "color": { "name": string, "code": string } }`
  - 201: `{ message, cart_item, cart_summary }`
- PUT `/cart/update_item/:product_id`
  - Body: `{ "quantity": integer, "color": { "name": string, "code": string } }`
  - 200: `{ message, cart_item, cart_summary }` (if quantity<=0, item removed)
- DELETE `/cart/remove_item/:product_id`
  - Body: `{ "color": { "name": string, "code": string } }`
  - 200: `{ message, cart_summary }`
- GET `/cart/checkout_eligibility`
  - 200: `{ eligible: boolean, message }`
- DELETE `/cart/clear`
  - 200: `{ message, cart_summary }`

Cart item shape:

```json
{
  "id": number,
  "product_id": number,
  "name": string,
  "price": number,
  "final_price": number,
  "discount": number,
  "quantity": number,
  "subtotal": number,
  "unit_final_price": number,
  "discount_amount": number,
  "image_url": string,
  "stock_quantity": number,
  "max_quantity": number,
  "color": { "name": string, "code": string }
}
```

### Orders

- GET `/orders`
  - Auth required; admins see all, customers see own
  - Pagination: `page`, `limit` (default 20)
  - 200: `{ orders: Order[], pagination }`
- GET `/orders/:id`
  - Auth required; admin or owner
  - 200: `Order` with `user` and item products (with `final_price`)
- POST `/orders`
  - Auth required
  - Body: `{ "payment_method": "credit_card"|"paypal"|"cash_on_delivery"|"bank_transfer", "shipping_address": { "street": string, "city": string, "state"?: string, "zip_code"?: string, "country"?: string } }`
  - 201: `{ success, message, order }`
- PATCH `/orders/:id/cancel`
  - Auth required; customer can cancel when status in `pending|confirmed`
  - 200: `{ success, message, order }`
- PATCH `/orders/:id/update_status`
  - Admin required
  - Body: `{ "status": "pending"|"confirmed"|"processing"|"shipped"|"delivered"|"cancelled" }`
  - 200: `{ success, message, order }`
- GET `/orders/stats`
  - Admin required
  - 200: `{ total_orders, pending_orders, revenue, recent_orders }`

### Common Notes

- Errors are returned as `{ errors: string[] }` or `{ success: false, error: string }` with appropriate HTTP status.
- Many list endpoints support pagination and include a `pagination` object with `current_page`, `total_pages`, `total_count`, and sometimes `per_page`.
- Role checks (`admin`, `customer`) are defined but some are currently not enforced in code; tokens still required for non-public endpoints.


