Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :auth_token, only:[:create] do
        post :refresh, on: :collection
        delete :destroy, on: :collection
      end 
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
