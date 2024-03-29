require 'sidekiq/web'

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
    root to: 'pages#home'
    resources :products, only: %i[index show new create edit update]
    resources :orders, only: %i[show update]
    resources :customers, only: %i[index show update]
    # sidekiq
    authenticate :admin do
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  # moudule (URLは変えずに、ファイル構成のみ指定のパスにする)
  scope module: :customer do
    resources :products, only: %i[index show]
    resources :cart_items, only: %i[index create destroy] do
      # cart内の個数を変更するためにpathにidを付与
      member do
        patch 'increase'
        patch 'decrease'
      end
    end
    resources :checkouts, only: [:create]
    resources :webhooks, only: [:create]
    resources :orders, only: %i[index show] do
      collection do
        get 'success'
      end
    end
    resources :customers do
      collection do
        get 'confirm_withdraw'
        patch 'withdraw'
      end
    end
  end

  get '/up/', to: 'up#index', as: :up
  get '/up/databases', to: 'up#databases', as: :up_databases
end
