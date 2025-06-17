Rails.application.routes.draw do
  resources :simulations, only: [ :index ] do
    collection do
      post :run
      get :reset
    end
  end
end
