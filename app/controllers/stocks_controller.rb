class StocksController < ApplicationController
  before_action :authenticate_user!, only: [:analyza, :industry, :all_years, :three_years, :five_years]

  def show
    @stock = Stock.find_by_easy_symbol!(params[:id])
    all_industrys = Stock.where(:industry => @stock.industry).where.not(:zcb => nil).where.not(:zcb => "")   # 捞出所属行业列表, 并筛选出资料不为空的数据"".where.not"方法"
    @industrys = all_industrys      #全部所属行业列表
    @industrys_cash_order = all_industrys.sort{ |x,y| y.cash_order <=> x.cash_order }[0..102]       #所属行业现金量排序
    @industrys_operating_margin_order = all_industrys.sort{ |x,y| y.operating_margin_order <=> x.operating_margin_order }[0..102]     #毛利率排序
    # @industrys_business_profitability_order = all_industrys.sort{ |x,y| y.business_profitability_order <=> x.business_profitability_order }[0..102]     #营业利益率排序
    @industrys_net_profit_margin_order = all_industrys.sort{ |x,y| y.net_profit_margin_order <=> x.net_profit_margin_order }[0..102]     #净利率排序
    @industrys_roe_order = all_industrys.sort{ |x,y| y.roe_order <=> x.roe_order }[0..102]       #股东权益报酬率 RoE 排序
    @industrys_debt_asset_order = all_industrys.sort{ |x,y| x.debt_asset_order <=> y.debt_asset_order }[0..102]       #负债占资本利率排序
    @time = 5

    # 笔记 note
    @stock_note_new = Note.new
    if current_user
      @stock_current_user_notes = @stock.notes.where( :user_id => current_user.id ).order("updated_at DESC")
    end
    @stock_notes = @stock.notes.where( :status => "公开" ).order("updated_at DESC")
  end


  # --- search 股票搜索 ---
  def search
    @query_string = params[:q].gsub(/\\|\'|\/|\?/, "") if params[:q].present?       # 拿到搜索框的 value 值
    if @query_string.present?
      @stock = Stock.find_by_easy_symbol!(@query_string.split(" - ")[0])            # 返回的是这样的结果:"600000,浦发银行,PFYX", 进行列表选择
      redirect_to stock_path(@stock)
    end
  end

  # --- 近十年财报 + 最新季报 VS 去年同期季报 ---  analyza_stocks_path
  def analyza
    @stock = Stock.find_by_easy_symbol!(params[:id])
    @time_years = 10
    @time_recent = 2
  end

  # --- 行业对比页面, 在页面中显示该行业中, 指标排名靠前的股票排名 ---
  def industry
    @all_user_choose_time_range_stocks = Stock.where(["time_to_market < ? ", user_choose_time_range_stocks ])     #所有符合用户选择股票的上市年限的股票
    @industry = params[:order]                                                      # 参数来源之show 页面的传入
    all_industrys = Stock.where(["time_to_market < ? ", user_choose_time_range_stocks ]).where(:industry => @industry).where.not(:zcb => nil).where.not(:zcb => "")      # 捞出所属行业列表, 并筛选出资料不为空的数据"".where.not"方法"
    @industrys = all_industrys      #全部所属行业列表
    @industrys_cash_order = all_industrys.sort{ |x,y| y.cash_order <=> x.cash_order }[0..30]       #所属行业现金量排序
    @industrys_operating_margin_order = all_industrys.sort{ |x,y| y.operating_margin_order <=> x.operating_margin_order }[0..30]     #毛利率排序
    @industrys_business_profitability_order = all_industrys.sort{ |x,y| y.business_profitability_order <=> x.business_profitability_order }[0..30]     #营业利益率排序
    @industrys_net_profit_margin_order = all_industrys.sort{ |x,y| y.net_profit_margin_order <=> x.net_profit_margin_order }[0..30]     #净利率排序
    @industrys_roe_order = all_industrys.sort{ |x,y| y.roe_order <=> x.roe_order }[0..30]       #股东权益报酬率 RoE 排序
    @industrys_debt_asset_order = all_industrys.sort{ |x,y| x.debt_asset_order <=> y.debt_asset_order }[0..30]       #负债占资本利率排序

    # 从"系统设置 - 行业"中提取行业列表
    @all_industrys = JSON.parse(Setting.first.industry)        # 所有行业信息
  end

  # --- 用户选择股票的上市年限 ---
  def all_years
    current_user.update!(
      :time_range => "all_years"
    )
    redirect_back fallback_location: industry_stocks_path
  end

  def three_years
    current_user.update!(
      :time_range => "three_years"
    )
    redirect_back fallback_location: industry_stocks_path
  end

  def five_years
    current_user.update!(
      :time_range => "five_years"
    )
    redirect_back fallback_location: industry_stocks_path
  end

  def user_choose_time_range_stocks
    if current_user.time_range == "all_years"
      range = Time.now
      return range
    elsif current_user.time_range == "three_years"
      range = Time.now - 1095.days
      return range
    elsif current_user.time_range == "five_years"
      range = Time.now - 1825.days
      return range
    end
  end
  # -------------------------------



end
