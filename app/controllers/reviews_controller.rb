class ReviewsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_user
  before_action :set_twitter

  def new
    @review = Review.new
  end

  def create
    @review = Review.new(review_params)
    @review.user_id = current_user.id
    @review.twitter_id = @twitter.id
    @review.save
  end

  private

  def set_user
    @user = User.find_by_username!(params[:user_id])
  end

  def set_twitter
    @twitter = Twitter.find(params[:twitter_id])
  end

  def review_params
    params.require(:review).permit(:content)
  end

end
