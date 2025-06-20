Rails.application.routes.draw do
  resources :simulations, only: [ :index ] do
    collection do
      post :run
      get :reset
      get :download_excel
      post :reset_and_seed
    end
  end

  root to: "simulations#index"
end
