class Admin::PostsController < AdminController
  before_action :set_course

  def new
    @post = Post.new
  end

  def show
    @post = Post.find(params[:id])
  end

  def create
    @post = Post.new(post_params)
    @post.course_id = @course.id
    if @post.save
      redirect_to admin_course_path(@course)
    else
      render :new
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    if @post.update(post_params)
      redirect_to admin_course_path(@course)
    else
      render :edit
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to admin_course_path(@course)
  end

  private

  def set_course
    @course = Course.find_by_friendly_id!(params[:course_id])
  end

  def post_params
    params.require(:post).permit(:title, :description, :catalog, :section, :status)
  end

end
