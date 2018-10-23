class PyramidController < ApplicationController

  impressionist actions: [:index]

  def index
    @stock_pyramid = JSON.parse(Setting.first.a_pyramid)
    @stocks = Stock.where(:easy_symbol => @stock_pyramid).order("pyramid_rating desc")
    @us_stock_pyramid = JSON.parse(Setting.first.us_pyramid)
    @us_stocks = UsStock.where(:easy_symbol => @us_stock_pyramid).order("pyramid_rating desc")
  end






  # 数据算法测试用页面
  def stock
    @stocks = Stock
    .where(["time_to_market < ? ", Time.now - 1095.days ])
    .where.not(:industry => "保险及其他")
    .where.not(:industry => "证券")
    .where.not(:industry => "银行")
    .order("pyramid_rating desc")[0..59]
  end

  def us_stock
    @us_stocks = UsStock
    .where.not(:industry => "财产保险公司")
    .where.not(:industry => "人寿保险")
    .where.not(:industry => "意外健康保险")
    .where.not(:industry => "专业保险公司")
    .where.not(:industry => "银行")
    .where.not(:industry => "商业银行")
    .where.not(:industry => "专业银行")
    .order("pyramid_rating desc")[0..59]
  end






end
