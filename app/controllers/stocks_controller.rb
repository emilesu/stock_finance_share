class StocksController < ApplicationController

  def show
    @stock = Stock.find_by_easy_symbol!(params[:id])
    @industrys = Stock.where(:industry => @stock.industry).all      # 所属行业列表
  end


  # --- search 股票搜索 ---
  def search
    @query_string = params[:q].gsub(/\\|\'|\/|\?/, "") if params[:q].present?       #拿到搜索框的 value 值
    if @query_string.present?
      @stock = Stock.find_by_easy_symbol!(@query_string.split(" - ")[0])            # 返回的是这样的结果:"600000,浦发银行,PFYX", 进行列表选择
      redirect_to stock_path(@stock)
    end
  end


end
