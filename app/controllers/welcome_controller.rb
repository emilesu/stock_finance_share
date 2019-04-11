class WelcomeController < ApplicationController

  impressionist actions: [:index2, :about]

  def index2
  end

  def about
    @setting = Setting.first
  end

  def company
  end

end
