class ContrastController < ApplicationController

  def search
    # -----拿到搜索框的 value 值-----
    query_param_a = params[:a].gsub(/\\|\'|\/|\?/, "") if params[:a].present?
    query_param_b = params[:b].gsub(/\\|\'|\/|\?/, "") if params[:b].present?
    query_param_c = params[:c].gsub(/\\|\'|\/|\?/, "") if params[:c].present?
    redirect_to contrast_index_path(:a => query_param_a, :b => query_param_b, :c => query_param_c)
  end

  def index
    a = params[:a]
    b = params[:b]
    c = params[:c]

    # 提取query_param_a数据 > data_a
    if a.present? && a.split(" - ")[-1] == "US"
      @stock_a = UsStock.find_by_easy_symbol!(a.split(" - ")[0])
      @stock_a_static_data = JSON.parse(@stock_a.static_data)
      @stcok_a_name = @stock_a.cnname
      @stcok_a_symbol = @stock_a.symbol
      @stock_a_syl = @stock_a.us_stock_latest_price_and_PE[2]
      @stock_a_gxl = @stock_a.us_stock_latest_price_and_PE[3]
      @stock_a_url = us_stock_path(@stock_a)
    else
      @stock_a = Stock.find_by_easy_symbol!(a.split(" - ")[0])
      @stock_a_static_data = JSON.parse(@stock_a.static_data_5)
      @stcok_a_name = @stock_a.name
      @stcok_a_symbol = @stock_a.easy_symbol
      @stock_a_syl = @stock_a.stock_latest_price_and_PE[2]
      @stock_a_gxl = @stock_a.the_dividend_yield
      @stock_a_url = stock_path(@stock_a)
    end
    # 提取query_param_b数据 > data_b
    if b.present? && b.split(" - ")[-1] == "US"
      @stock_b = UsStock.find_by_easy_symbol!(b.split(" - ")[0])
      @stock_b_static_data = JSON.parse(@stock_b.static_data)
      @stcok_b_name = @stock_b.cnname
      @stcok_b_symbol = @stock_b.symbol
      @stock_b_syl = @stock_b.us_stock_latest_price_and_PE[2]
      @stock_b_gxl = @stock_b.us_stock_latest_price_and_PE[3]
      @stock_b_url = us_stock_path(@stock_b)
    else
      @stock_b = Stock.find_by_easy_symbol!(b.split(" - ")[0])
      @stock_b_static_data = JSON.parse(@stock_b.static_data_5)
      @stcok_b_name = @stock_b.name
      @stcok_b_symbol = @stock_b.easy_symbol
      @stock_b_syl = @stock_b.stock_latest_price_and_PE[2]
      @stock_b_gxl = @stock_b.the_dividend_yield
      @stock_b_url = stock_path(@stock_b)
    end
    # 提取query_param_c数据 > data_c
    if !c.blank?
      if c.present? && c.split(" - ")[-1] == "US"
        @stock_c = UsStock.find_by_easy_symbol!(c.split(" - ")[0])
        @stock_c_static_data = JSON.parse(@stock_c.static_data)
        @stcok_c_name = @stock_c.cnname
        @stcok_c_symbol = @stock_c.symbol
        @stock_c_syl = @stock_c.us_stock_latest_price_and_PE[2]
        @stock_c_gxl = @stock_c.us_stock_latest_price_and_PE[3]
        @stock_c_url = us_stock_path(@stock_c)
      else
        @stock_c = Stock.find_by_easy_symbol!(c.split(" - ")[0])
        @stock_c_static_data = JSON.parse(@stock_c.static_data_5)
        @stcok_c_name = @stock_c.name
        @stcok_c_symbol = @stock_c.easy_symbol
        @stock_c_syl = @stock_c.stock_latest_price_and_PE[2]
        @stock_c_gxl = @stock_c.the_dividend_yield
        @stock_c_url = stock_path(@stock_c)
      end
    end
  end



end
