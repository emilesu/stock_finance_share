class Admin::CoursesController < AdminController

  def index
    @courses = Course.all.order("created_at DESC")
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      redirect_to admin_courses_path
    else
      render :new
    end
  end

  def edit
    @course = Course.find_by_friendly_id!(params[:id])
  end

  def update
    @course = Course.find_by_friendly_id!(params[:id])
    if @course.update(course_params)
      redirect_to admin_courses_path
    else
      render :edit
    end
  end

  def destroy
    @course = Course.find_by_friendly_id!(params[:id])
    @course.destroy
    redirect_to admin_courses_path
  end

  private
  def course_params
    params.require(:course).permit(:title, :description, :friendly_id)
  end

end
