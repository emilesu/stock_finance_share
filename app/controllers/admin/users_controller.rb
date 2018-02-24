class Admin::UsersController < AdminController

  def index
    @users = User.all.page(params[:page]).per(25)
  end

  def show
    @user = User.find_by_username!(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save!
      redirect_to admin_users_path
    else
      render :new
    end
  end

  def edit
    @user = User.find_by_username!(params[:id])
  end

  def update
    @user = User.find_by_username!(params[:id])
    if @user.update(user_params)
      redirect_to admin_users_path
    else
      render :edit
    end
  end

  private
  def user_params
    params.require(:user).permit(:avatar, :username, :motto, :role, :email, :password, :password_confirmation)
  end

end
