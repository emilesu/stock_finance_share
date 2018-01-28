class Admin::BaseDataController < AdminController

  def index
    #code
  end

  # 全局扫描更新 沪股 股票代码和名称
  def update_sh_stock_symbol

    (1..2).each do |i|        #最终上线要改为18
      response = RestClient.get "http://web.juhe.cn:8080/finance/stock/shall", :params => { :key => KEY_CONFIG["juhe_api_key"], :page => i, :type => "1" }
      data = JSON.parse(response.body)

      data["result"]["data"].each do |s|
        existing_stock = Stock.find_by_symbol( s["symbol"] )
        if existing_stock.nil?
          Stock.create!(
            :symbol => s["symbol"],
            :name => s["name"],
            :easy_symbol => s["symbol"][2..7]
          )
        end
      end
    end
    puts "更新完毕*******"
    redirect_to admin_base_data_index_path
    flash[:notice] = "沪股 股票代码和名称 已在更新"

  end

  # 全局扫描更新 沪股 股票代码和名称
  def update_sz_stock_symbol

    (1..2).each do |i|        #最终上线要改为27
      response = RestClient.get "http://web.juhe.cn:8080/finance/stock/szall", :params => { :key => KEY_CONFIG["juhe_api_key"], :page => i, :type => "1" }
      data = JSON.parse(response.body)

      data["result"]["data"].each do |s|
        existing_stock = Stock.find_by_symbol( s["symbol"] )
        if existing_stock.nil?
          Stock.create!(
            :symbol => s["symbol"],
            :name => s["name"],
            :easy_symbol => s["symbol"][2..7]
          )
        end
      end
    end
    puts "更新完毕*******"
    redirect_to admin_base_data_index_path
    flash[:notice] = "深股 股票代码和名称 已在更新"

  end

  #全局扫描更新 三表数据 股票行业
  def update_stock_finance_table
    @stocks = Stock.all
    @stocks.each do |s|

      # zcb 资产表更新
      response_zcb = RestClient.get "http://future.liangyee.com/bus-api/corporateFinance/MainStockFinance/getBalanceSheet", :params => { :userKey => KEY_CONFIG["liangyee_api_key"], :symbol => s.easy_symbol, :yearly => true }
      data_zcb = JSON.parse(response_zcb.body)
      s.update!(
        :zcb => data_zcb["result"],
      )

      # lrb 利润表更新
      response_lrb = RestClient.get "http://future.liangyee.com/bus-api/corporateFinance/MainStockFinance/getStockProfit", :params => { :userKey => KEY_CONFIG["liangyee_api_key"], :symbol => s.easy_symbol, :yearly => true }
      data_lrb = JSON.parse(response_lrb.body)
      s.update!(
        :lrb => data_lrb["result"],
      )

      # llb 流量表更新
      response_llb = RestClient.get "http://future.liangyee.com/bus-api/corporateFinance/MainStockFinance/getStockCashFlow", :params => { :userKey => KEY_CONFIG["liangyee_api_key"], :symbol => s.easy_symbol, :yearly => true }
      data_llb = JSON.parse(response_llb.body)
      s.update!(
        :llb => data_llb["result"],
      )

      # fzb 负债表更新
      response_fzb = RestClient.get "http://future.liangyee.com/bus-api/corporateFinance/MainStockFinance/GetBalanceSheetLiabilities", :params => { :userKey => KEY_CONFIG["liangyee_api_key"], :symbol => s.easy_symbol, :yearly => true }
      data_fzb = JSON.parse(response_fzb.body)
      s.update!(
        :fzb => data_fzb["result"],
      )

      # gdb 股东权益表更新
      response_gdb = RestClient.get "http://future.liangyee.com/bus-api/corporateFinance/MainStockFinance/GetBalanceSheetShareholder", :params => { :userKey => KEY_CONFIG["liangyee_api_key"], :symbol => s.easy_symbol, :yearly => true }
      data_gdb = JSON.parse(response_gdb.body)
      s.update!(
        :gdb => data_gdb["result"],
      )

      # industry 行业分类更新
      existing_stock_industry = s.industry
      if existing_stock_industry.nil?
        response_industry = RestClient.get "http://future.liangyee.com/bus-api/corporateFinance/MainStockFinance/GetStockIndustryClassification", :params => { :userKey => KEY_CONFIG["liangyee_api_key"], :symbol => s.easy_symbol }
        data_industry = JSON.parse(response_industry.body)["result"]
        main_data = data_industry[0]
        if !main_data.nil?
          s.update!(
            :industry => main_data.split(",")[2],
          )
        end
      end

    end
    puts "更新完毕*******"
    redirect_to admin_base_data_index_path
    flash[:notice] = "三表数据 股票行业 更新完毕"
  end


  #全局扫描更新 股票主营业务
  def update_stock_main_business
    @stocks = Stock.all
    @stocks.each do |s|

      if s.main_business.nil?
      response = RestClient.get "http://quotes.money.163.com/f10/gszl_#{s.easy_symbol}.html#11a01"
      doc = Nokogiri::HTML.parse(response.body)
      main = doc.css(".table_bg001[3] tr[11]").map{ |x| x.text }[0].split(" ")
        s.update!(
          :main_business => main[1],
        )
      end
    end
    puts "更新完毕*******"
    redirect_to admin_base_data_index_path
    flash[:notice] = "主营业务 更新完毕"
  end


end
