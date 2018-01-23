class StocksController < ApplicationController

  def show
    @stock = Stock.find_by_symbol!(params[:id])
  end

end
