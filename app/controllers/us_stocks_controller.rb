class UsStocksController < ApplicationController

  def show
    @us_stock = UsStock.find_by_easy_symbol!(params[:id])

    # 股票现价\涨跌幅\市盈率\股息率 数列式
    @latest_price = @us_stock.us_stock_latest_price_and_PE
  end

end
