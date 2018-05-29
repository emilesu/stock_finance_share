class UsTrade < ApplicationRecord

  #与 user 关系
  belongs_to :user

  # 资料验证
  validates_presence_of :stock, :buy_price, :buy_time

  TRADE_STATUS = ["公开", "对会员公开", "私密"]
  validates_inclusion_of :status, :in => TRADE_STATUS

end
