Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"
      get "auth/me", to: "auth#me"
      patch "auth/update_profile", to: "auth#update_profile"
      post "auth/change_password", to: "auth#change_password"

      get "filter", to: "product_specs#index"

      # Resources
      resources :categories, only: [ :index, :show, :create, :update, :destroy ] do
        resources :sub_categories, only: [ :index, :create ]
      end

      resources :sub_categories, only: [ :index, :show, :create, :update, :destroy ]

      resources :products, only: [ :index, :show, :create, :update, :destroy ] do
        resources :reviews, only: [ :index, :create ]
        member do
          patch :add_sales
          patch :add_rating
        end
      end

      resources :users, only: [ :index, :show, :create, :update, :destroy ] do
        member do
          get :customers
        end
      end

      resources :reviews, only: [ :update, :destroy ]

      resource :cart, only: [] do
        member do
          get "/", to: "carts#show"
          get "/checkout_eligibility", to: "carts#checkout_eligibility"
          post "add_item/:product_id", to: "carts#add_item"
          put "update_item/:product_id", to: "carts#update_item"
          delete "remove_item/:product_id", to: "carts#remove_item"
          delete "clear", to: "carts#clear"
        end
      end

      resources :orders, only: [ :index, :show, :create ] do
        member do
          patch :cancel
          patch :update_status
        end
        collection do
          get :stats
        end
      end
    end
  end
end
