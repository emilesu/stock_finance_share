class Admin::StocksController < AdminController

  def index
    # @stocks = Stock.order("symbol").page(params[:page]).per(25)
    @industry = params[:order]
    if @industry.nil?
      @stocks = Stock.order("symbol").page(params[:page]).per(25)                   # 如果参数为空，则显示所有数据
    else
      @stocks = Stock.where(:industry => @industry).page(params[:page]).per(25)         #筛选出传入参数所属行业的数据
    end

    # 行业筛选
    @industry_list = JSON.parse(Setting.first.a_industry)
  end

  def show
    @stock = Stock.find_by_easy_symbol!(params[:id])
  end

  def new
    @stock = Stock.new
  end

  def create
    @stock = Stock.new(stock_params)

    if @stock.save
      redirect_to admin_stocks_path
    else
      render :new
    end
  end

  def edit
    @stock = Stock.find_by_easy_symbol!(params[:id])
  end

  def update
    @stock = Stock.find_by_easy_symbol!(params[:id])

    if @stock.update(stock_params)
      redirect_to admin_stocks_path
    else
      render :edit
    end
  end

  def destroy
    @stock = Stock.find_by_easy_symbol!(params[:id])

    @stock.destroy
    redirect_to admin_stocks_path
  end


  private

  def stock_params
    params.require(:stock).permit(:symbol, :easy_symbol, :name, :lrb, :llb, :zcb, :fzb, :gdb, :industry, :main_business, :regional, :company_url, :time_to_market, :pinyin, :dividends, :static_data_10, :static_data_5, :static_data_2)
  end

end
