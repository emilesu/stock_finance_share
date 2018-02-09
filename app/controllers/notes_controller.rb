class NotesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_stock

  def new
    @note = Note.new
  end

  def create
    @note = Note.new(note_params)
    @note.user_id = current_user.id
    @note.stock_id = @stock.id

    if @note.save
      redirect_back fallback_location: stock_path(@stock)
    else
      redirect_back fallback_location: stock_path(@stock)
    end
  end

  def edit
    @note = Note.find(params[:id])
  end

  def update
    @note = Note.find(params[:id])

    if @note.update(note_params)
      redirect_back fallback_location: stock_path(@stock)
    else
      redirect_back fallback_location: stock_path(@stock)
    end
  end

  def destroy
    @note = Note.find(params[:id])

    @note.destroy
    redirect_back fallback_location: stock_path(@stock)
  end

  private

  def set_stock
    @stock = Stock.find_by_easy_symbol!(params[:stock_id])
  end

  def note_params
    params.require(:note).permit(:stock_id, :user_id, :status, :level, :title, :description)
  end

end
