Rails.application.routes.draw do
  devise_for :users, controllers: {
    :omniauth_callbacks => "omniauth_callbacks"
  }

  # A股路由设置
  resources :stocks do
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

  # 美股路由设置
  resources :us_stocks do
    collection do
      get :search                   #搜索并打开 功能
      get "/industry/" => "us_stocks#industry", :as =>:industry                 #行业对比页面
      get "/sector/" => "us_stocks#sector", :as =>:sector                 #领域对比页面
    end
    resources :us_notes do
      member do
        post "like" => "us_notes#like"             #增加 赞/收藏
        post "unlike" => "us_notes#unlike"         #取消 赞/收藏
      end
    end
  end

  namespace :pyramid do             # 长期上涨潜力排行表
    get :stock                      # 数据算法测试用页面
    get :us_stock                   # 数据算法测试用页面
    get :index                      # 正式页面 调用静态数据
  end

  namespace :contrast do            #股票对比
    get :search
    get :index
    get :vs
  end

  resources :users do
    resources :twitters do
      resources :reviews
    end
    resources :trades
    resources :us_trades
    member do
      post "fan" => "users#fan"
      delete "un_fan" => "users#un_fan"
    end
  end

  resources :courses do             #课程展示
    resources :posts
  end

  resources :videos          #视频教程

  resources :new_infos       #新内容

  namespace :admin do
    resources :users do
      member do
        post "nper_1" => "users#nper_1"         #增加1年会员
        post "nper_99" => "users#nper_99"       #永久会员
        post "undo" => "users#undo"             #撤销会员
      end
    end
    resources :stocks
    resources :us_stocks
    resources :settings
    resources :courses do           #课程后台编辑
      resources :posts
    end
    namespace :base_data do
      get :index                    #首台数据更新主页
        # --------------A股部分 --------------
      post :update_sh_stock_symbol     #更新 沪市 股票代码和股票名称
      post :update_sz_stock_symbol     #更新 沪市 股票代码和股票名称
      post :update_stock_finance_table    #更新财务表表数据
      post :update_stock_dividends    #更新 分红 数据
      post :update_static_data        #更新 数据静态保存
      post :update_industry_info    #更新财务表表数据
      post :update_stock_company_info    #更新股票主营业务
      post :update_stock_time_to_market    #更新股票主营业务
      post :update_industry_setting    #更新行业设置
      post :update_stock_pyramid_rating_data    #更新 pyramid_rating 数据静态化
      post :update_a_pyramid_setting    #更新pyramid设置

        # --------------美股部分 --------------
      post :update_us_stock_symbol     #更新 美股 代码、上市地
      post :update_us_stock_finance_table     #全局扫描更新 财务表 数据
      post :update_us_stock_static_data       #更新 美股 数据静态保存
      post :update_us_stock_company_info       #更新 美股 中文名 行业
      post :update_us_industry_setting    #更新行业设置
      post :update_us_stock_pyramid_rating_data    #更新 pyramid_rating 数据静态化
      post :update_us_pyramid_setting    #更新pyramid设置

        # --------------百度链接推送--------------
      post :baidu_url_push     #主动推送（实时）
    end
    resources :videos          #视频教程

    resources :new_infos          #新内容
  end

  # 社群论坛 homeland
  resources :homelands do             #社群论坛
    collection do
      get :search
    end
    member do
      post "like" => "homelands#like"             #增加 赞/收藏
      post "unlike" => "homelands#unlike"         #取消 赞/收藏
    end
    resources :homeland_posts do
      member do
        post "like" => "homeland_posts#like"             #增加 赞/收藏
        post "unlike" => "homeland_posts#unlike"         #取消 赞/收藏
      end
    end
  end

  # 论坛图片上传
  post 'upload' => "photos#upload"

  # 加入会员页面
  namespace :join do
    get :index                  #加入会员文案页
    get :go_wechat_pay
    get :wx_pay_qrcode
    post :is_wxpay_success
    get :to_be_member
    post :wx_pay_notify
  end


  namespace :welcome do
    get :index2
    get :about
  end

  root "welcome#index2"
end
