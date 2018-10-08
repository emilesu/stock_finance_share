class WelcomeController < ApplicationController

  impressionist actions: [:index2]

  def index2
  end

  def about
    @setting = Setting.first
  end

end
