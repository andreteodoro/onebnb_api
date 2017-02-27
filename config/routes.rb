Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth'
      get 'users/wishlist', to: 'users#wishlist'
      put 'users', to: 'users#update'
      get 'current_user', to: 'users#current_user'

      get 'search', to: 'properties#search'
      get 'autocomplete', to: 'properties#autocomplete'
      get 'featured', to: 'properties#featured'
      get 'trips', to: 'properties#trips'
      get 'my_properties', to: 'properties#my_properties'

      resources :properties do
        member do
          post 'wishlist', to: 'properties#add_to_wishlist'
          delete 'wishlist', to: 'properties#remove_from_wishlist'
        end
      end

      resources :talks do
        member do
          get 'messages', to: 'talks#messages'
        end
      end
      get 'talks', to: 'talks#index'
      post 'talks/(:id)/messages', to: 'talks#create_message'

      resources :reservations do
        member do
          post 'evaluation', to: 'reservations#evaluation'
        end
      end
    end
  end
end
