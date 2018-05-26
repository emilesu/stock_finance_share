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


  # -----------------------------------财报季度数据整理脚本-----------------------------------
  #                         由于美股的数据只有5位，所以每串只输出5个数据
  # -----------------------------------报表数据算法脚本-----------------------------------

  # 由于原数据的数字字符串中包含有逗号“,”的分隔，在转成数字的时候会导致缺失不准确，因此做 to_m函数来统一格式化
  def to_num(x)
    if x.nil?
      return 0
    elsif x.include?(",")
      sp = x.split(",")
      m = ""
      (0..sp.size - 1).each do |i|
        m = m + sp[i]
      end
      return m.to_f
    else
      return x.to_f
    end
  end

  # 年份列表
  def us_stock_years
    date = JSON.parse(self.cwzb)[0]
    # 运算
    result = []
    (0..4).each do |i|
      if date[i].nil?
        m = 0
      else
        m = date[i]
      end
      result << m
    end
    return result
  end


  # --- A1-1、现金流量比率（  >100%比较好 ）---
  # =  经营净现金流llb9  /  流动负债zcb17
  def us_operating_cash_flow_ratio
    # 数据提取
    llb9 = JSON.parse(self.llb)[9]
    zcb17 = JSON.parse(self.zcb)[17]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb17[i]) != 0
         m = to_num(llb9[i]) / to_num(zcb17[i]) * 100
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- A1-3、现金再投资比率（  >10%比较好 ）---
  # =  经营净现金流llb9 - 红利支付llb17  /  总资产zcb15 - 流动负债zcb17
  def us_cash_re_investment_ratio
    # 数据提取
    llb9 = JSON.parse(self.llb)[9]
    llb17 = JSON.parse(self.llb)[17]
    zcb15 = JSON.parse(self.zcb)[15]
    zcb17 = JSON.parse(self.zcb)[17]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb15[i]) - to_num(zcb17[i]) != 0
         m = (to_num(llb9[i]) - to_num(llb17[i])) / (to_num(zcb15[i]) - to_num(zcb17[i])) * 100
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- A2-1、现金与约当现金占总资产比率 ( 10% - 25% 较好 ) ---
  # =  现金与约当现金 zcb3  /  总资产 zcb15
  def us_cash_and_cash_equivalents_ratio
    # 数据提取
    zcb3 = JSON.parse(self.zcb)[3]
    zcb15 = JSON.parse(self.zcb)[15]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb15[i]) != 0
         m = to_num(zcb3[i]) / to_num(zcb15[i]) * 100
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- A2-2、应收账款占总资产比率 ---
  # =  应收账款 zcb5  /  总资产 zcb15
  def us_receivables_ratio
    # 数据提取
    zcb5 = JSON.parse(self.zcb)[5]
    zcb15 = JSON.parse(self.zcb)[15]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb15[i]) != 0
         m = to_num(zcb5[i]) / to_num(zcb15[i]) * 100
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- A2-3、存货占总资产比率 ---
  # =  存货 zcb6  /  总资产 zcb15
  def us_inventory_ratio
    # 数据提取
    zcb6 = JSON.parse(self.zcb)[6]
    zcb15 = JSON.parse(self.zcb)[15]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb15[i]) != 0
         m = to_num(zcb6[i]) / to_num(zcb15[i]) * 100
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- A2-4、流动资产占总资产比率 ---
  # =  流动资产 zcb2  /  总资产 zcb15
  def us_current_assets_ratio
    # 数据提取
    zcb2 = JSON.parse(self.zcb)[2]
    zcb15 = JSON.parse(self.zcb)[15]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb15[i]) != 0
         m = to_num(zcb2[i]) / to_num(zcb15[i]) * 100
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- A2-5、应付账款占总资产比率 ---
  # =  应付账款 zcb19  /  总资产 zcb15
  def us_accounts_payable_ratio
    # 数据提取
    zcb19 = JSON.parse(self.zcb)[19]
    zcb15 = JSON.parse(self.zcb)[15]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb15[i]) != 0
         m = to_num(zcb19[i]) / to_num(zcb15[i]) * 100
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- A2-6、流动负债占总资产比率 ---
  # =  流动负债 zcb17  /  总资产 zcb15
  def us_current_liabilities_ratio
    # 数据提取
    zcb17 = JSON.parse(self.zcb)[17]
    zcb15 = JSON.parse(self.zcb)[15]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb15[i]) != 0
         m = to_num(zcb17[i]) / to_num(zcb15[i]) * 100
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- A2-7、长期负债占总资产比率 ---
  # =  非流动负债 zcb22  /  总资产 zcb15
  def us_long_term_liability_ratio
    # 数据提取
    zcb22 = JSON.parse(self.zcb)[22]
    zcb15 = JSON.parse(self.zcb)[15]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb15[i]) != 0
         m = to_num(zcb22[i]) / to_num(zcb15[i]) * 100
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- A2-8、股东权益占总资产比率 ---
  # =  股东权益 zcb27  /  总资产 zcb15
  def us_shareholders_equity_ratio
    # 数据提取
    zcb27 = JSON.parse(self.zcb)[27]
    zcb15 = JSON.parse(self.zcb)[15]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb15[i]) != 0
         m = to_num(zcb27[i]) / to_num(zcb15[i]) * 100
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- A3-1、应收账款周转率 ---
  # =  营业收入  lrb1  /  应收账款 zcb5
  def us_accounts_receivable_turnover_ratio
    # 数据提取
    lrb1 = JSON.parse(self.lrb)[1]
    zcb5 = JSON.parse(self.zcb)[5]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb5[i]) != 0
         m = to_num(lrb1[i]) / to_num(zcb5[i])
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- A3-2、存货周转率 ---
  # =  营业成本  lrb2  /  存货 zcb6
  def us_inventory_turnover_ratio
    # 数据提取
    lrb2 = JSON.parse(self.lrb)[2]
    zcb6 = JSON.parse(self.zcb)[6]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb6[i]) != 0
         m = to_num(lrb2[i]) / to_num(zcb6[i])
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- A3-3、固定资产周转率(不动产/厂房及设备周转率) ---
  # =  营业收入  lrb1  /  不动产/厂房及设备 zcb11
  def us_fixed_asset_turnover_ratio
    # 数据提取
    lrb1 = JSON.parse(self.lrb)[1]
    zcb11 = JSON.parse(self.zcb)[11]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb11[i]) != 0
         m = to_num(lrb1[i]) / to_num(zcb11[i])
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- A3-4、总资产周转率 ---
  # =  营业收入  lrb1  /  总资产 zcb15
  def us_total_asset_turnover_ratio
    # 数据提取
    lrb1 = JSON.parse(self.lrb)[1]
    zcb15 = JSON.parse(self.zcb)[15]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb15[i]) != 0
         m = to_num(lrb1[i]) / to_num(zcb15[i])
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- C1、营业毛利率 ---
  # =  营业毛利率 cwzb10
  def us_operating_margin_ratio
    # 数据提取
    cwzb10 = JSON.parse(self.cwzb)[10]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(cwzb10[i]) != 0
         m = to_num(cwzb10[i])
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- C2、营业利益率 ---
  # =  营业利益率 cwzb12
  def us_business_profitability_ratio
    # 数据提取
    cwzb12 = JSON.parse(self.cwzb)[12]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(cwzb12[i]) != 0
         m = to_num(cwzb12[i])
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- C3、经营安全边际率 ---
  # =  营业利益率 cwzb12 / 营业毛利率 cwzb10
  def us_operating_margin_of_safety_ratio
    # 数据提取
    cwzb12 = JSON.parse(self.cwzb)[12]
    cwzb10 = JSON.parse(self.cwzb)[10]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(cwzb10[i]) != 0
         m = to_num(cwzb12[i]) / to_num(cwzb10[i]) * 100
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- C4、净利率 ---
  # =  净利率 cwzb13
  def us_net_profit_margin_ratio
    # 数据提取
    cwzb13 = JSON.parse(self.cwzb)[13]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(cwzb13[i]) != 0
         m = to_num(cwzb13[i])
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- C5、每股盈余 ---
  # =  每股收益 cwzb27
  def us_earnings_per_share
    # 数据提取
    cwzb27 = JSON.parse(self.cwzb)[27]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(cwzb27[i]) != 0
         m = to_num(cwzb27[i])
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- C5-1、税后净利(百万元) ---
  # =  净利润 lrb14
  def us_after_tax_profit
    # 数据提取
    lrb14 = JSON.parse(self.lrb)[14]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(lrb14[i]) != 0
         m = to_num(lrb14[i])
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- C6、股东权益报酬率 ---
  # =  归属于母公司所有者的净利润 lrb16 / 归属于母公司股东权益合计 zcb29
  def us_roe_ratio
    # 数据提取
    lrb16 = JSON.parse(self.lrb)[16]
    zcb29 = JSON.parse(self.zcb)[29]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb29[i]) != 0
         m = to_num(lrb16[i]) / to_num(zcb29[i]) * 100
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- D1、负债占资产比率 ---
  # =  总负债 zcb25 / 总资产 zcb15
  def us_debt_asset_ratio
    # 数据提取
    zcb25 = JSON.parse(self.zcb)[25]
    zcb15 = JSON.parse(self.zcb)[15]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb15[i]) != 0
         m = to_num(zcb25[i]) / to_num(zcb15[i]) * 100
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- D2、长期负债占不动产/厂房及设备比率 ---
  # =  (长期负债 zcb22 + 股东权益 zcb27) / 不动产/厂房及设备 zcb11
  def us_long_term_funds_for_fixed_assets_ratio
    # 数据提取
    zcb22 = JSON.parse(self.zcb)[22]
    zcb27 = JSON.parse(self.zcb)[27]
    zcb11 = JSON.parse(self.zcb)[11]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb11[i]) != 0
         m = (to_num(zcb22[i]) + to_num(zcb27[i])) / to_num(zcb11[i]) * 100
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end

  # --- E1、流动比率 ---
  # =  流动比率 cwzb22
  def us_current_ratio
    # 数据提取
    cwzb22 = JSON.parse(self.cwzb)[22]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(cwzb22[i]) != 0
         m = to_num(cwzb22[i]) * 100
       else
         m = 0
       end
       result << m.round(0)
    end
    return result
  end

  # --- E2、速动比率 ---
  # =  速动比率 cwzb24
  def us_quick_ratio
    # 数据提取
    cwzb24 = JSON.parse(self.cwzb)[24]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(cwzb24[i]) != 0
         m = to_num(cwzb24[i]) * 100
       else
         m = 0
       end
       result << m.round(0)
    end
    return result
  end

  # --- F1、经营活动现金流量 ---
  # =  经营活动产生现金流量净额 llb9
  def us_net_cash_flow_of_business_activities
    # 数据提取
    llb9 = JSON.parse(self.llb)[9]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(llb9[i]) != 0
         m = to_num(llb9[i])
       else
         m = 0
       end
       result << m.round(0)
    end
    return result
  end

  # --- F2、投资活动现金流量 ---
  # =  投资活动产生现金流量净额 llb15
  def us_net_investment_activities_generated_cash_flow
    # 数据提取
    llb15 = JSON.parse(self.llb)[15]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(llb15[i]) != 0
         m = to_num(llb15[i])
       else
         m = 0
       end
       result << m.round(0)
    end
    return result
  end

  # --- F2、筹资活动现金流量(百万元) ---
  # =  筹资活动产生的现金流量净额 llb21
  def us_net_financing_activities_generated_cash_flow
    # 数据提取
    llb21 = JSON.parse(self.llb)[21]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(llb21[i]) != 0
         m = to_num(llb21[i])
       else
         m = 0
       end
       result << m.round(0)
    end
    return result
  end

  # --- G-2、分红金额( b.派息 ) ---
  # =  红利支付 llb17
  def us_dividend_amount
    # 数据提取
    llb17 = JSON.parse(self.llb)[17]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(llb17[i]) != 0
         m = to_num(llb17[i])
       else
         m = 0
       end
       result << m.round(0)
    end
    return result
  end

  # --- G-3、分红率 ---
  # = 红利支付 llb17 / 属总公司净利润 lrb16
  def us_dividend_rate
    # 数据提取
    llb17 = JSON.parse(self.llb)[17]
    lrb16 = JSON.parse(self.lrb)[16]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(lrb16[i]) != 0
         m = to_num(llb17[i]) / to_num(lrb16[i]) * 100
       else
         m = 0
       end
       result << m.round(2)
    end
    return result
  end



  # ---------------------- 数据静态化保存 ----------------------

  def us_stock_static_data
    sd = []
    sd << self.us_stock_years                                       # 0-年报年度
    sd << self.us_cash_and_cash_equivalents_ratio                   # 1-现金与约当现金
    sd << self.us_receivables_ratio                                 # 2-应收账款
    sd << self.us_inventory_ratio                                   # 3-存货
    sd << self.us_current_assets_ratio                              # 4-流动资产
    sd << self.us_accounts_payable_ratio                            # 5-应付账款
    sd << self.us_current_liabilities_ratio                         # 6-流动负债
    sd << self.us_long_term_liability_ratio                         # 7-长期负债
    sd << self.us_shareholders_equity_ratio                         # 8-股东权益
    sd << self.us_accounts_receivable_turnover_ratio                # 9-应收账款周转率
    sd << self.us_inventory_turnover_ratio                          # 10-存货周转率
    sd << self.us_fixed_asset_turnover_ratio                        # 11-不动产/厂房及设备周转率
    sd << self.us_total_asset_turnover_ratio                        # 12-总资产周转率
    sd << self.us_roe_ratio                                         # 13-股东权益报酬率 ROE
    sd << self.us_operating_margin_ratio                            # 14-营业毛利率
    sd << self.us_business_profitability_ratio                      # 15-营业利益率
    sd << self.us_operating_margin_of_safety_ratio                  # 16-经营安全边际率
    sd << self.us_net_profit_margin_ratio                           # 17-净利率
    sd << self.us_earnings_per_share                                # 18-每股盈余
    sd << self.us_after_tax_profit                                  # 19-税后净利
    sd << self.us_debt_asset_ratio                                  # 20-负债占资产比率
    sd << self.us_long_term_funds_for_fixed_assets_ratio            # 21-长期负债占不动产/厂房及设备比率
    sd << self.us_current_ratio                                     # 22-流动比率
    sd << self.us_quick_ratio                                       # 23-速动比率
    sd << self.us_net_cash_flow_of_business_activities              # 24-经营活动现金流量
    sd << self.us_net_investment_activities_generated_cash_flow     # 25-投资活动现金流量
    sd << self.us_net_financing_activities_generated_cash_flow      # 26-筹资活动现金流量
    sd << self.us_operating_cash_flow_ratio                         # 27-现金流量比率
    sd << self.us_cash_re_investment_ratio                          # 28-现金再投资比率
    sd << self.us_dividend_amount                                   # 29-分红金额
    sd << self.us_dividend_rate                                     # 30-分红率
    self.update!(
      :static_data => sd
    )
  end



  # -----------------modal 弹窗数据脚本, 将输出[时间+数据]的格式用于生成图表-----------------

  # 财报类 时间为按年
  def modal_data(time, data)
    #判断时间,以确定生成的数据长度
    y = JSON.parse(self.static_data)[0][0..4]
    #与日期对应的数据,生成具体的数据
    m = data
    # 运算
    result = []
    (0..time-1).each do |i|
      main_y = y[i]
      data = [main_y, m[i]]
      result << data
    end
    # 返回 modal 数据
    return result
  end

  # 分红类 时间为按红利发放日
  def modal_dividends_data(time, data)
    #判断时间,以确定生成的数据长度
    y = JSON.parse(self.static_data)[0][0..4]
    #与日期对应的数据,生成具体的数据
    m = data
    # 运算
    result = []
    (0..time-1).each do |i|
      main_y = y[i]
      data = [main_y, m[i]]
      result << data
    end
    # 返回 modal 数据
    return result
  end




end
