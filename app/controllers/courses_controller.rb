class CoursesController < ApplicationController

  impressionist actions: [:show]

  def index
    @courses = Course.all
  end

  def show
    @course = Course.find_by_friendly_id!(params[:id])
    @posts = @course.posts.order("catalog")
  end

end
