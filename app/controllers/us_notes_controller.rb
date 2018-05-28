class UsNotesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_stock

  def new
    @us_note = UsNote.new
  end

  def create
    @us_note = UsNote.new(note_params)
    @us_note.user_id = current_user.id
    @us_note.us_stock_id = @us_stock.id

    if @us_note.save
      redirect_back fallback_location: stock_path(@us_stock)
    else
      redirect_back fallback_location: stock_path(@us_stock)
    end
  end

  def edit
    @us_note = UsNote.find(params[:id])
  end

  def update
    @us_note = UsNote.find(params[:id])

    if @us_note.update(note_params)
      redirect_back fallback_location: stock_path(@us_stock)
    else
      redirect_back fallback_location: stock_path(@us_stock)
    end
  end

  def destroy
    @us_note = UsNote.find(params[:id])

    @us_note.destroy
    redirect_back fallback_location: stock_path(@us_stock)
  end

  # 赞/收藏功能
  def like
    @us_note = UsNote.find(params[:id])
    unless @us_note.find_us_like(current_user)    # 如果已经按讚过了，就略过不再新增
      UsLike.create( :user => current_user, :us_note => @us_note )
    end
  end

  def unlike
    @us_note = UsNote.find(params[:id])
    us_like = @us_note.find_us_like(current_user)
    us_like.destroy
    render "like"
  end

  private

  def set_stock
    @us_stock = UsStock.find_by_easy_symbol!(params[:us_stock_id])
  end

  def note_params
    params.require(:us_note).permit(:us_stock_id, :user_id, :status, :level, :title, :description)
  end

end
