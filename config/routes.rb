Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    get :index                      #后台主页
    namespace :base_data do
      get :index                    #首台数据更新主页
      post :update_stock_symbol     #更新股票代码和股票名称
      post :update_stock_finance_table    #更新鬼片财务表表数据
    end
  end

end
