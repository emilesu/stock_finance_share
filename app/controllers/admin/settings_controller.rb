class Admin::SettingsController < AdminController

  def index
    @settings = Setting.all
    @stocks = Stock.all.page(params[:page]).per(100)
    @us_stocks = UsStock.all.page(params[:page]).per(300)
  end

  def show
    #code
  end

  def new
    @setting = Setting.new
  end

  def create
    @setting = Setting.new(setting_params)

    if @setting.save
      redirect_to admin_settings_path
    else
      render :new
    end
  end

  def edit
    @setting = Setting.find(params[:id])
  end

  def update
    @setting = Setting.find(params[:id])

    if @setting.update(setting_params)
      redirect_to admin_settings_path
    else
      render :edit
    end
  end

  def destroy
    @setting = Setting.find(params[:id])

    @setting.destroy
    redirect_to admin_settings_path
  end


  private

  def setting_params
    params.require(:setting).permit(
      :industry,
      :version_1,
      :version_2,
      :version_3,
      :version_4,
      :version_5,
      :us_version_1,
      :us_version_2,
      :us_version_3,
      :us_version_4,
      :us_version_5
    )
  end

end
