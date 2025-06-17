Rails.application.routes.draw do
  resources :simulations, only: [ :index ] do
    collection do
      post :run
      get :reset
      get :download_excel
    end
  end
end
