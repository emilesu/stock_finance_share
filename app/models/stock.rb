class Stock < ApplicationRecord

  # ---去掉‘sh’或’sz‘后的股票代码 symbol---
  def easy_symbol
    self.symbol[2..7]
  end
  
end
