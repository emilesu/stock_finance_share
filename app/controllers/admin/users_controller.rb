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
      # 注册后直接和站长建立关联
      @user.attentions.create!(
        :user_id => @user.id,
        :my_attention => User.find_by_role("admin").id
      )
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

  def destroy
    @user = User.find_by_username!(params[:id])
    @user.destroy
    redirect_to admin_users_path
  end

  #--- 会员加入设置 ---

  # 加入会员一年
  def nper_1
    @user = User.find_by_username!(params[:id])
    if @user.join_time.blank?                     #如果用户是第一次加入,则加入日期是当日,结束日期是一年后
      @user.update!(
        :join_time => Time.now,
        :end_time => Time.now + 365.days,
        :nper => 1
      )
    else                                          #如果用户续签一期, 则在原来的基础上 + 1
      if @user.end_time > Time.now                #如果在上一期到期之前续签, 则在上一期的结尾增加一年
        @user.update!(
          :end_time => @user.end_time + 365.days,
        )
      else                                        #如果在上一期到期之后续签, 则在当日基础上增加一年
        @user.update!(
          :end_time => Time.now + 365.days,
        )
      end
      @user.update!(
        :nper => @user.nper + 1
      )
    end
    if @user.role == "nonmember"                  #判断用户权限状态
      @user.update!(
        :role => "member"
      )
    end
    redirect_to admin_users_path
  end

  # 加入会员永久
  def nper_99
    @user = User.find_by_username!(params[:id])
    if @user.join_time.blank?                     #如果用户是第一次加入
      @user.update!(
        :join_time => Time.now,
        :end_time => Time.now + 20000.days,
        :nper => 99
      )
    else                                          #如果用户之前已加入
      @user.update!(
        :end_time => Time.now + 20000.days,
        :nper => 99
      )
    end
    if @user.role == "nonmember"                  #判断用户权限状态
      @user.update!(
        :role => "member"
      )
    end
    redirect_to admin_users_path
  end

  # 撤销会员
  def undo
    @user = User.find_by_username!(params[:id])
    if @user.role == "member"
      @user.update!(
        :role => "nonmember",
        :join_time => nil,
        :end_time => nil,
        :nper => nil
      )
    end
    redirect_to admin_users_path
  end

  #---end 会员加入设置 end---

  private
  def user_params
    params.require(:user).permit(
      :avatar,                          #头像
      :username,                        #用户名
      :motto,                           #个人简介
      :role,                            #用户权限
      :email,                           #email
      :password,                        #密码
      :password_confirmation,           #确认密码
      :join_time,                       #加入会员时间
      :end_time,                        #会员到期时间
      :nper                             #会员期数
    )
  end

end
