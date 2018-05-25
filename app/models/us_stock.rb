class UsStock < ApplicationRecord

  # 资料验证
  validates_presence_of :symbol, :cnname

  # 与 note 关系
  has_many :notes

  # ---把网址改成股票代码---
  def to_param
    self.symbol
  end

end
