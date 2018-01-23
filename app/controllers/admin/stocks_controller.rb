class Admin::StocksController < AdminController

  def index
    @stocks = Stock.all.order("symbol")
  end

  def show
    @stock = Stock.find_by_easy_symbol!(params[:id])
  end

  def new
    @stock = Stock.new
  end

  def create
    @stock = Stcok.new(stock_params)

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
    params.require(:stock).permit(:symbol, :easy_symbol, :name, :lrb, :llb, :zcb, :fzb, :gdb, :industry)
  end

end
