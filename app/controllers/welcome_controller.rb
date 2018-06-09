class WelcomeController < ApplicationController

  def index2
  end

  def about
    @setting = Setting.first
  end

end
