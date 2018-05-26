class UsStock < ApplicationRecord

  # 资料验证
  validates_presence_of :symbol, :easy_symbol, :cnname

  # 新增的时候，总统添加 easy_symbole
  # 每股中因为有的 symbol 存在点"."的情况，不能作为 routes 路径，所以必须把“.”转化为"_"。
  before_validation :add_easy_symbol, :on => :create

  def add_easy_symbol
    if self.symbol.include?(".")
      self.easy_symbol ||= self.symbol.split(".")[0] + "_" + self.symbol.split(".")[1]
    else
      self.easy_symbol ||= self.symbol
    end
  end

  # ---把网址改成股票代码---
  def to_param
    self.easy_symbol
  end


  # 与 note 关系
  has_many :notes


end
