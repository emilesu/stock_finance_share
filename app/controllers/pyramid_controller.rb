class PyramidController < ApplicationController

  def stock
    @stocks = Stock.all.sort{ |x,y| y.stock_main_pyramid <=> x.stock_main_pyramid }[0..50]
  end

  def us_stock
    @us_stocks = UsStock.all.sort{ |x,y| y.us_stock_main_pyramid <=> x.us_stock_main_pyramid }[0..50]
  end

end
