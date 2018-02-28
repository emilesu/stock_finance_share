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
      rendew :new
    else
  end

  def edit
    @course = Course.find(params[:id])
  end

  def update
    @course = Course.find(params[:id])
    if @course.update(course_params)
      redirect_to admin_courses_path
    else
      rendew :edit
    else
  end

  def destroy
    @course = Course.find(params[:id])
    @course.destroy
    redirect_to admin_courses_path
  end

  private
  def course_params
    params.require(:course).permit(:title, :description)
  end

end
