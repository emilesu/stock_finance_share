class WelcomeController < ApplicationController

  impressionist actions: [:index2, :about]

  def index2
    @new_infos = NewInfo.all.order("created_at desc").page(params[:page]).per(6)
  end

  def about
    @setting = Setting.first
  end

end
