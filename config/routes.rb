Rails.application.routes.draw do
  devise_for :users

  resources :stocks do
    # get "/industry/" => "stocks#industry", :as => :industry        #行业关键指标排名分析
    collection do
      get "/analyza/:id" => "stocks#analyza", :as => :analyza        #近十年财报 + 最新季报 VS 去年同期季报    get "/analyza/" => "stocks#analyza", :as => :analyza        #近十年财报 + 最新季报 VS 去年同期季报
      get "/statements/:id" => "stocks#statements", :as => :statements        #近十年财报原报
      get :search                   #搜索并打开 功能
      get "/industry/" => "stocks#industry", :as =>:industry                 #行业对比页面

      # 用户点击选择股票上市年限 按钮
      post :all_years
      post :three_years
      post :five_years
    end

    # 股票笔记功能
    resources :notes do
      member do
        post "like" => "notes#like"             #增加 赞/收藏
        post "unlike" => "notes#unlike"         #取消 赞/收藏
      end
    end
  end

  namespace :admin do
    resources :stocks
    resources :settings
    namespace :base_data do
      get :index                    #首台数据更新主页
      post :update_sh_stock_symbol     #更新 沪市 股票代码和股票名称
      post :update_sz_stock_symbol     #更新 沪市 股票代码和股票名称
      post :update_stock_finance_table    #更新财务表表数据
      post :update_industry_info    #更新财务表表数据
      post :update_stock_company_info    #更新股票主营业务
      post :update_stock_time_to_market    #更新股票主营业务
      post :update_industry_setting    #更新行业设置
    end
  end



  #异步管理 UI
  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.role == "admin" } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root "welcome#index"
end
