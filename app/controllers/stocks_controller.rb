class StocksController < ApplicationController

  def show
    @stock = Stock.find_by_easy_symbol!(params[:id])
    all_industrys = Stock.where(:industry => @stock.industry).all      # 捞出所属行业列表
    @industrys = all_industrys      #全部所属行业列表
    @industrys_cash_order = all_industrys.sort{ |x,y| y.cash_order <=> x.cash_order }       #所属行业现金量排序
    @industrys_operating_margin_order = all_industrys.sort{ |x,y| y.operating_margin_order <=> x.operating_margin_order }     #毛利率排序
    @industrys_net_profit_margin_order = all_industrys.sort{ |x,y| y.net_profit_margin_order <=> x.net_profit_margin_order }     #净利率排序
    @industrys_roe_order = all_industrys.sort{ |x,y| y.roe_order <=> x.roe_order }       #股东权益报酬率 RoE 排序
    @industrys_debt_asset_order = all_industrys.sort{ |x,y| x.debt_asset_order <=> y.debt_asset_order }       #负债占资本利率排序
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
