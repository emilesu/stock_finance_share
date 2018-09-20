class Admin::BaseDataController < AdminController

  def index
  end

# ______________________________________A股部分______________________________________

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
    flash[:notice] = "沪股 股票代码和名称 更新完毕"

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
    flash[:notice] = "深股 股票代码和名称 更新完毕"

  end

  #全局扫描更新 三表数据 股票行业
  def update_stock_finance_table
    require 'csv'                       #引入 csv 库
    @stocks = Stock.all
    @stocks.each do |s|

      if s.version_1 != Setting.first.version_1
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
        :version_1 => Setting.first.version_1
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

      if s.version_2 != Setting.first.version_2 || s.version_2.blank?
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
          :dividends => result
        )
      end
      s.update!(
        :version_2 => Setting.first.version_2
      )
    end
    puts "更新完毕*******"
    redirect_to admin_base_data_index_path
    flash[:notice] = "股票分红数据 更新完毕"
  end


  # 数据静态保存
  def update_static_data
    @stocks = Stock.all
    @stocks.each do |s|
      if s.version_3 != Setting.first.version_3
        s.static_data
      end
      s.update!(
        :version_3 => Setting.first.version_3
      )
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
       :a_industry => x
     )
     puts "更新完毕*******"
     redirect_to admin_base_data_index_path
     flash[:notice] = "行业设置 设置完毕"
   end











# ______________________________________美股部分______________________________________

  # 全局扫描更新 更新 美股 代码、上市地
  # (旧版)
  # def update_us_stock_symbol
  #
  #   (1..150).each do |i|        #最终上线要"i"改为149+ , "type"改为3
  #     response = RestClient.get "http://web.juhe.cn:8080/finance/stock/usaall", :params => { :key => KEY_CONFIG["juhe_api_key"], :page => i, :type => "3" }
  #     data = JSON.parse(response.body)
  #
  #     data["result"]["data"].each do |s|
  #       existing_stock = UsStock.find_by_symbol( s["symbol"] )
  #       if existing_stock.nil?
  #         UsStock.create!(
  #           :symbol => s["symbol"],
  #           :market => s["market"]
  #         )
  #       end
  #     end
  #   end
  #   puts "更新完毕*******"
  #   redirect_to admin_base_data_index_path
  #   flash[:notice] = "美股 代码、股票名称、行业、上市地 更新完毕"
  #
  # end


  # 更新美股列表、行业 数据汇入   数据源 NASDAQ CSV表
  # (2018.09.20版本)
  def update_us_stock_symbol
    require 'csv'                       #引入 csv 库
    csv_string = params[:csv_file].read.force_encoding('utf-8')    #数据源来自上传的 CSV 文件

    success = 0
    failed_records = []

    CSV.parse(csv_string) do |row|
      us_stock = UsStock.new(
        :symbol => row[0],
        :name => row[1],
        :ipoyear => row[4],
        :sector => row[5],
        :industry => row[6],
      )

      if us_stock.save
        success += 1
      else
        failed_records << [row, us_stock]
        Rails.logger.info("#{row} ----> #{us_stock.errors.full_messages}")
      end
    end

    puts "更新完毕*******"
    flash[:notice] = "总共汇入 #{success} 笔，失败 #{failed_records.size} 笔"
    redirect_to admin_base_data_index_path

  end



  # 全局扫描更新 财务表 数据
  def update_us_stock_finance_table
    @us_stocks = UsStock.all
    @us_stocks.each do |s|

      if s.us_version_1 != Setting.first.us_version_1
        # -------从网易提取原始数据 cwzb-------
        cwzb_response = RestClient.get "http://quotes.money.163.com/usstock/#{s.symbol}_indicators.html?type=year"
        cwzb_doc = Nokogiri::HTML.parse(cwzb_response.body)
        cwzb_result = []
        # 报告日期放在最前面
        cwzb_date = cwzb_doc.css(".list_table_wrapper ul li").map{ |x| x.text }
        cwzb_result << cwzb_date
        # 具体各行数据
        (1..28).each do |i|
          cwzb_result << cwzb_doc.css(".list_table_wrapper tbody tr[#{i}] td").map{ |x| x.text }
        end
        s.update!(
          :cwzb => cwzb_result
        )

        # -------从网易提取原始数据 zcb-------
        zcb_response = RestClient.get "http://quotes.money.163.com/usstock/#{s.symbol}_balance.html?type=year"
        zcb_doc = Nokogiri::HTML.parse(zcb_response.body)
        zcb_result = []
        # 报告日期放在最前面
        zcb_date = zcb_doc.css(".list_table_wrapper ul li").map{ |x| x.text }
        zcb_result << zcb_date
        # 具体各行数据
        (1..31).each do |i|
          zcb_result << zcb_doc.css(".list_table_wrapper tbody tr[#{i}] td").map{ |x| x.text }
        end
        s.update!(
          :zcb => zcb_result
        )

        # -------从网易提取原始数据 lrb-------
        lrb_response = RestClient.get "http://quotes.money.163.com/usstock/#{s.symbol}_income.html?type=year"
        lrb_doc = Nokogiri::HTML.parse(lrb_response.body)
        lrb_result = []
        # 报告日期放在最前面
        lrb_date = lrb_doc.css(".list_table_wrapper ul li").map{ |x| x.text }
        lrb_result << lrb_date
        # 具体各行数据
        (1..21).each do |i|
          lrb_result << lrb_doc.css(".list_table_wrapper tbody tr[#{i}] td").map{ |x| x.text }
        end
        s.update!(
          :lrb => lrb_result
        )

        # -------从网易提取原始数据 llb-------
        llb_response = RestClient.get "http://quotes.money.163.com/usstock/#{s.symbol}_cash.html?type=year"
        llb_doc = Nokogiri::HTML.parse(llb_response.body)
        llb_result = []
        # 报告日期放在最前面
        llb_date = llb_doc.css(".list_table_wrapper ul li").map{ |x| x.text }
        llb_result << llb_date
        # 具体各行数据
        (1..26).each do |i|
          llb_result << llb_doc.css(".list_table_wrapper tbody tr[#{i}] td").map{ |x| x.text }
        end
        s.update!(
          :llb => llb_result
        )
      end
      s.update!(
        :us_version_1 => Setting.first.us_version_1
      )
    end
    puts "更新完毕*******"
    redirect_to admin_base_data_index_path
    flash[:notice] = "财务表 更新完毕"
  end



  # 数据静态保存
  def update_us_stock_static_data
    @us_stock = UsStock.all
    @us_stock.each do |s|
      if s.us_version_3 != Setting.first.us_version_3
        s.us_stock_static_data
      end
      s.update!(
        :us_version_3 => Setting.first.us_version_3
      )
    end
    puts "更新完毕*******"
    redirect_to admin_base_data_index_path
    flash[:notice] = "美股 数据静态保存 更新完毕"
  end



  #全局扫描更新 股票信息 中文名 行业
  def update_us_stock_company_info
    @us_stocks = UsStock.all
    @us_stocks.each do |s|

      if s.cnname.blank? || s.industry.blank?
        response = RestClient.get "https://www.laohu8.com/hq/s/#{s.easy_symbol}"
        doc = Nokogiri::HTML.parse(response.body)
          main1 = doc.css(".quote-main .title").map{ |x| x.text }[0].split(" ")[1..-1].join(" ")
          if doc.css(".quote-main .belong").map{ |x| x.text }[0].nil?
            main2 = "其他"        #爬取的数据有时会存在 nil 的情况，独自区分为 “其他”
          else
            main2 = doc.css(".quote-main .belong").map{ |x| x.text }[0].split("：")[1]
          end
          s.update!(
            :cnname => main1,
            :industry => main2
          )
      end
    end
    puts "更新完毕*******"
    redirect_to admin_base_data_index_path
    flash[:notice] = "股票 中文名 行业 更新完毕"
  end


  #更新行业设置
   def update_us_industry_setting
     @all_industrys = UsStock.all_industrys_li           # scope :all_industrys_li
     x = []
     @all_industrys.each do |i|
       x << i
     end
     Setting.first.update!(
       :us_industry => x
     )
     puts "更新完毕*******"
     redirect_to admin_base_data_index_path
     flash[:notice] = "行业设置 设置完毕"
   end


end
