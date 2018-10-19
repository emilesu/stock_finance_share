class PyramidController < ApplicationController

  def stock
    @stocks = Stock
    .where(["time_to_market < ? ", Time.now - 1095.days ])
    .where.not(:industry => "保险及其他")
    .where.not(:industry => "证券")
    .where.not(:industry => "银行")
    .sort{ |x,y| y.stock_main_pyramid <=> x.stock_main_pyramid }[0..50]
  end

  def us_stock
    @us_stocks = UsStock
    .where.not(:industry => "专业保险公司")
    .where.not(:industry => "商业银行")
    .where.not(:industry => "专业银行")
    .sort{ |x,y| y.us_stock_main_pyramid <=> x.us_stock_main_pyramid }[0..50]
  end

end
