Rails.application.routes.draw do
  devise_for :users

  resources :stocks do
    collection do
      get :search                   #搜索并打开 功能
    end
  end

  namespace :admin do
    resources :stocks
    namespace :base_data do
      get :index                    #首台数据更新主页
      post :update_sh_stock_symbol     #更新 沪市 股票代码和股票名称
      post :update_sz_stock_symbol     #更新 沪市 股票代码和股票名称
      post :update_stock_finance_table    #更新财务表表数据
      post :update_stock_main_business    #更新股票主营业务
    end
  end

  #异步管理 UI
  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.role == "admin" } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root "welcome#index"
end
