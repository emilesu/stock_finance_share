class StocksController < ApplicationController

  def show
    @stock = Stock.find_by_easy_symbol!(params[:id])
    
    # 所属行业列表
    @industrys = Stock.where(:industry => @stock.industry).all
  end

end
