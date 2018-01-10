class Admin::BaseDataController < AdminController

  def index
    #code
  end

  # 全局扫描更新 沪股 股票代码和名称
  def update_stock_symbol

    response = RestClient.get "http://web.juhe.cn:8080/finance/stock/shall", :params => { :key => JUHE_CONFIG["api_key"], :page => "2", :type => "4" }
    data = JSON.parse(response.body)

    data["result"]["data"].each do |s|
      existing_stock = Stock.find_by_symbol( s["symbol"] )
      if existing_stock.nil?
        Stock.create!(
          :symbol => s["symbol"],
          :name => s["name"]
        )
      end
    end
    puts "更新完毕*******"

  end




end
