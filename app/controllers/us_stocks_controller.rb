class UsStocksController < ApplicationController

  def show
    @us_stock = UsStock.find_by_easy_symbol!(params[:id])


    # 笔记 note
    @note_new = UsNote.new
    if current_user
      @current_user_notes = @us_stock.us_notes.where( :user_id => current_user.id ).order("updated_at DESC")
    end
    @notes = @us_stock.us_notes.order("updated_at DESC").page(params[:notes]).per(20)

    # 股票现价\涨跌幅\市盈率\股息率 数列式
    @latest_price = @us_stock.us_stock_latest_price_and_PE
  end

end
