class JoinController < ApplicationController

  before_action :authenticate_user! , only: [:go_wechat_pay, :wx_pay_qrcode]

  def index
    #code
  end

  # 生成订单信息
  def go_wechat_pay
    params = {
      body: 'HOLD LE - 会员VIP（第二期）',
      out_trade_no: Time.now.to_s(:number),
      attach: current_user.id.to_s,
      total_fee: 1,
      spbill_create_ip: '127.0.0.1',
      notify_url: 'https://www.holdle.com/join/wx_pay_notify',
      trade_type: 'NATIVE' # could be "MWEB", ""JSAPI", "NATIVE" or "APP",
      # openid: 'OPENID' # required when trade_type is `JSAPI`
    }
    result = WxPay::Service.invoke_unifiedorder params
    redirect_to join_wx_pay_qrcode_path(:code_url => result["code_url"])
  end

  # 二维码页面
  def wx_pay_qrcode
    @qr = RQRCode::QRCode.new(params[:code_url])
    # @qr = RQRCode::QRCode.new("http://github.com/")
  end

  # 扫码后显示的 ajax 页面
  def is_wxpay_success
    user = User.find_by_user_id(params[:user_id])
    # if user.role == "member"
    if user.motto == "小猪佩奇"
      logger.info "======扫码支付成功====="
      render :json => {
        :is_pay_success => "yes"
      }
    else
      logger.info "======未支付====="
      render :json => {
        :is_pay_success => "no"
      }
    end
  end

  # 成为会员提示页面
  def to_be_member
    @user = User.find_by(params[:user_id])
  end

  # 回调和操作
  def wx_pay_notify
    Rails.logger.info "=============== 扫码支付成功,后台回调 =============="
    result = Hash.from_xml(request.body.read)["xml"]
    if WxPay::Sign.verify?(result)
      logger.info "======== 验证签名成功 ======= "
      user_id = result["attach"].to_i
      user = User.find_by_user_id(user_id)
      user.update!(
        # :join_time => Time.now,
        # :end_time => Time.now + 20000.days,
        # :nper => 99,
        # :role => "member"
        :motto => "小猪佩奇"
      )
      render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
    else
      render :xml => {return_code: "FAIL", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
    end
  end



end
