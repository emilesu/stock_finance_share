class Admin::BaseDataController < AdminController

  def index
    #code
  end

  # 全局扫描更新 沪股 股票代码和名称
  def update_sh_stock_symbol

    (1..18).each do |i|        #最终上线要改为18
      response = RestClient.get "http://web.juhe.cn:8080/finance/stock/shall", :params => { :key => KEY_CONFIG["juhe_api_key"], :page => i, :type => "4" }
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

    (1..27).each do |i|        #最终上线要改为27
      response = RestClient.get "http://web.juhe.cn:8080/finance/stock/szall", :params => { :key => KEY_CONFIG["juhe_api_key"], :page => i, :type => "4" }
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

      if s.version != Setting.first.version
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

      s.update!(
        :version => Setting.first.version
      )

    end
    puts "更新完毕*******"
    redirect_to admin_base_data_index_path
    flash[:notice] = "三表数据 股票行业 更新完毕"
  end


  # 全局扫描更新 分红 数据
  def update_stock_dividends
    @stocks = Stock.all
    @stocks.each do |s|

      if s.version != Setting.first.version
        # 从网易提取原始数据
        response = RestClient.get "http://quotes.money.163.com/f10/fhpg_#{s.easy_symbol}.html#10d01"
        doc = Nokogiri::HTML.parse(response.body)
        # 数据处理 提取格式 [[a.分红年份, b.派息, c.派发日], [a.分红年份, b.派息, c.派发日], ....]
        result = []
        (0..10).each do |i|
          data = []
          if doc.css(".table_bg001 tr td[2]").map{ |x| x.text }[i].blank?
            a = "--"
          else
            a = doc.css(".table_bg001 tr td[2]").map{ |x| x.text }[i]
          end
          if doc.css(".table_bg001 tr td[5]").map{ |x| x.text }[i].blank?
            b = "--"
          else
            b = doc.css(".table_bg001 tr td[5]").map{ |x| x.text }[i]
          end
          if doc.css(".table_bg001 tr td[7]").map{ |x| x.text }[i].blank?
            c = "--"
          else
            c = doc.css(".table_bg001 tr td[7]").map{ |x| x.text }[i]
          end
          data << a
          data << b
          data << c
          result << data
        end
        s.update!(
          :dividends => result,
          :version => Setting.first.version
        )
      end
    end
    puts "更新完毕*******"
    redirect_to admin_base_data_index_path
    flash[:notice] = "股票分红数据 更新完毕"
  end


  # 数据静态保存
  def update_static_data
    @stocks = Stock.all
    @stocks.each do |s|
      if s.version != Setting.first.version
        s.static_data
      end
    end
    puts "更新完毕*******"
    redirect_to admin_base_data_index_path
    flash[:notice] = "股票数据静态保存 更新完毕"
  end


  # 全局扫描更新 行业更新
  def update_industry_info
    @stocks = Stock.all
    @stocks.each do |s|

      # industry 行业分类更新
      response = RestClient.get "http://stockpage.10jqka.com.cn/#{s.easy_symbol}/field/#fieldstatus"
      doc = Nokogiri::HTML.parse(response.body)
      # if s.industry.nil?
      main = doc.css(".threecate").map{ |x| x.text }[0]
      if !main.nil?
        s.update!(
          :industry => main.split("--")[1].strip,
        )
      else
        s.update!(
          :industry => "暂无",
        )
      end
      # end

    end
    puts "更新完毕*******"
    redirect_to admin_base_data_index_path
    flash[:notice] = "行业 更新完毕"
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


  #全局扫描更新 股票上市时间
  def update_stock_time_to_market
    @stocks = Stock.all
    @stocks.each do |s|

      if s.time_to_market.nil?
        response = RestClient.get "http://app.finance.ifeng.com/data/stock/gpjk.php?symbol=#{s.easy_symbol}"
        doc = Nokogiri::HTML.parse(response.body)
          main = doc.css("table tr[5] td").map{ |x| x.text }[1].split(" ")[-8]
          s.update!(
            :time_to_market => main
          )
      end

      if s.pinyin.nil?
        response = RestClient.get "http://app.finance.ifeng.com/data/stock/gpjk.php?symbol=#{s.easy_symbol}"
        doc = Nokogiri::HTML.parse(response.body)
          main = doc.css("table tr[3] td").map{ |x| x.text }[1]
          s.update!(
            :pinyin => main
          )
      end

    end
    puts "更新完毕*******"
    redirect_to admin_base_data_index_path
    flash[:notice] = "股票上市时间 拼音简称 更新完毕"
  end


  #更新行业设置
   def update_industry_setting
     @all_industrys = Stock.all_industrys_li           # scope :all_industrys_li
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
