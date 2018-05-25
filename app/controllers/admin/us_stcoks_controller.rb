class Admin::UsStcoksController < AdminController

  def index
    # @us_stocks = UsStock.order("symbol").page(params[:page]).per(25)
    @industry = params[:order]
    if @industry.nil?
      @us_stocks = UsStock.order("symbol").page(params[:page]).per(25)                   # 如果参数为空，则显示所有数据
    else
      @us_stocks = UsStock.where(:industry => @industry).page(params[:page]).per(25)         #筛选出传入参数所属行业的数据
    end

    # 行业筛选
    @industry_list = JSON.parse(Setting.first.industry)
  end

  def show
    @us_stock = UsStock.find_by_symbol!(params[:id])
  end

  def new
    @us_stock = UsStock.new
  end

  def create
    @us_stock = UsStock.new(us_stock_params)

    if @us_stock.save
      redirect_to admin_UsStocks_path
    else
      render :new
    end
  end

  def edit
    @us_stock = UsStock.find_by_symbol!(params[:id])
  end

  def update
    @us_stock = UsStock.find_by_symbol!(params[:id])

    if @us_stock.update(us_stock_params)
      redirect_to admin_UsStocks_path
    else
      render :edit
    end
  end

  def destroy
    @us_stock = UsStock.find_by_symbol!(params[:id])

    @us_stock.destroy
    redirect_to admin_UsStocks_path
  end


  private

  def us_stock_params
    params.require(:us_stock).permit(:symbol, :cnname, :market, :pinyin, :cwzb, :lrb, :llb, :zcb, :industry, :main_business, :company_url, :time_to_market, :dividends, :static_data_10, :static_data_5, :static_data_2)
  end

end
