class WelcomeController < ApplicationController
  def index
    @stock = Stock.last
  end
end
