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
    require 'csv'                       #引入 csv 库
    @stocks = Stock.all
    @stocks.each do |s|

      # zcb 资产表更新
      response_zcb = RestClient.get "http://quotes.money.163.com/service/zcfzb_#{s.easy_symbol}.html"
      data_zcb = CSV.parse(response_zcb, :headers => true)
      s.update!(
        :zcb => data_zcb,
      )

      # lrb 利润表更新
      response_lrb = RestClient.get "http://quotes.money.163.com/service/lrb_#{s.easy_symbol}.html"
      data_lrb = CSV.parse(response_lrb, :headers => true)
      s.update!(
        :lrb => data_lrb,
      )

      # llb 流量表更新
      response_llb = RestClient.get "http://quotes.money.163.com/service/xjllb_#{s.easy_symbol}.html"
      data_llb = CSV.parse(response_llb, :headers => true)
      s.update!(
        :llb => data_llb,
      )

    end
    puts "更新完毕*******"
    redirect_to admin_base_data_index_path
    flash[:notice] = "三表数据 股票行业 更新完毕"
  end


  # 全局扫描更新 行业更新
  def update_industry_info
    @stocks = Stock.all
    @stocks.each do |s|

      # industry 行业分类更新
      response = RestClient.get "http://quotes.money.163.com/f10/hydb_#{s.easy_symbol}.html#01g02"
      doc = Nokogiri::HTML.parse(response.body)
      # if s.industry.nil?
      main = doc.css(".inner_box a").map{ |x| x.text }[0].split(" ")
        s.update!(
          :industry => main[0],
        )
      # end

    end
    puts "更新完毕*******"
    redirect_to admin_base_data_index_path
    flash[:notice] = "三表数据 行业 更新完毕"
  end


  #全局扫描更新 股票主营业务
  def update_stock_company_info
    @stocks = Stock.all
    @stocks.each do |s|


      response = RestClient.get "http://quotes.money.163.com/f10/gszl_#{s.easy_symbol}.html#11a01"
      doc = Nokogiri::HTML.parse(response.body)

      # 更新主营业务
      if s.main_business.nil?
      main = doc.css(".table_bg001[3] tr[11]").map{ |x| x.text }[0].split(" ")
        s.update!(
          :main_business => main[1],
        )
      end

      # 更新公司地域
      if s.regional.nil?
      main = doc.css(".table_bg001[3] tr[1]").map{ |x| x.text }[0].split(" ")
        s.update!(
          :regional => main[-1],
        )
      end

      # 更新公司网址
      if s.company_url.nil?
      main = doc.css(".table_bg001[3] tr[9]").map{ |x| x.text }[0].split(" ")
        s.update!(
          :company_url => main[1],
        )
      end

    end
    puts "更新完毕*******"
    redirect_to admin_base_data_index_path
    flash[:notice] = "主营业务 更新完毕"
  end

  #更新行业设置
   def update_industry_setting
     @all_industrys = Stock.all_industrys_li
     x = []
     @all_industrys.each do |i|
       x << i
     end
     Setting.first.update!(
       :industry => x
     )
     puts "更新完毕*******"
     redirect_to admin_base_data_index_path
     flash[:notice] = "行业设置 设置完毕"
   end

end
