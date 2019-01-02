class JoinController < ApplicationController

  before_action :authenticate_user! , only: [:go_wechat_pay, :wx_pay_qrcode]

  def index
    #code
  end

  def go_wechat_pay
    params = {
      body: 'HOLD LE 会员VIP - 168元',
      out_trade_no: Time.now.to_s(:number),
      total_fee: 1,
      spbill_create_ip: '127.0.0.1',
      notify_url: 'https://www.holdle.com/join/wx_pay_notify',
      trade_type: 'NATIVE' # could be "MWEB", ""JSAPI", "NATIVE" or "APP",
      # openid: 'OPENID' # required when trade_type is `JSAPI`
    }
    result = WxPay::Service.invoke_unifiedorder params
    redirect_to join_wx_pay_qrcode_path(:code_url => result["code_url"])
  end

  def wx_pay_qrcode
    # @qr = RQRCode::QRCode.new(params[:code_url])
    @qr = RQRCode::QRCode.new("http://github.com/")
  end

  def wx_pay_notify
    #code
  end

end
