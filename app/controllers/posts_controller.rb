class PostsController < ApplicationController
  before_action :set_course

  def show
    @post = Post.find(params[:id])
  end

  private

  def set_course
    @course = Course.find_by_friendly_id!(params[:course_id])
  end

end
