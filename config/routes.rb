Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Resources
      resources :categories, only: [:index, :show, :create, :update, :destroy]
      resources :products, only: [:index, :show, :create, :update, :destroy]
    end
  end
end
