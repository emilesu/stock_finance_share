class UsStocksController < ApplicationController

  def show
    @us_stock = UsStock.find_by_easy_symbol!(params[:id])
  end

end
