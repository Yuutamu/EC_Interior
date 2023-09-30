Rails.application.routes.draw do
  devise_for :admins, controllers: {
    sessions: 'admin/sessions'
  }
  devise_for :customers, controllers: {
    sessions: 'customer/sessions',
    registrations: 'customer/registrations'
  }
  root to: 'pages#home'

  # namespace (URL, ファイル構成 ともに指定のパスにする)
  namespace :admin do
    resources :products, only: %i[index show new create edit update]
  end

  # moudule (URLは変えずに、ファイル構成のみ指定のパスにする)
  scope module: :customer do
    resources :products, only: %i[index show]
  end

  get '/up/', to: 'up#index', as: :up
  get '/up/databases', to: 'up#databases', as: :up_databases
end
