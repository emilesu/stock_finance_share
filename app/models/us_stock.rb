class UsStock < ApplicationRecord

  # 资料验证
  validates_presence_of :symbol, :easy_symbol

  # 新增的时候，总统添加 easy_symbole
  # 每股中因为有的 symbol 存在点"."的情况，不能作为 routes 路径，所以必须把“.”转化为"_"。
  before_validation :add_easy_symbol, :on => :create

  def add_easy_symbol
    if self.symbol.include?(".")
      self.easy_symbol ||= self.symbol.split(".")[0] + "-" + self.symbol.split(".")[1]
    else
      self.easy_symbol ||= self.symbol
    end
  end


  # ---把网址改成股票代码---
  def to_param
    self.easy_symbol
  end

  # ---捞出 所有的 sector 和 industrys 行业, 并且去重---
  scope :all_sectors_li, -> { pluck(:sector).uniq }       # pluck 方法捞出指定字段的资料
  scope :all_industrys_li, -> { pluck(:industry).uniq }       # pluck 方法捞出指定字段的资料

  # 与 note 关系
  has_many :us_notes


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
    date = JSON.parse(self.zcb)[0]
    # 运算
    result = []
    (0..4).each do |i|
      if date[i].nil?
        m = "0"
      else
        d = date[i].split("/")                      # 对时间进行格式化
        m = d[2] + "-" + d[0] + "-" + d[1]          # 把 1/30/2018 转换成 2018-1-31
      end
      result << m
    end
    return result
  end


  # --- A1-1、现金流量比率（  >100%比较好 ）---
  # =  经营净现金流llb9  /  流动负债zcb20
  def us_operating_cash_flow_ratio
    # 数据提取
    llb9 = JSON.parse(self.llb)[9]
    zcb20 = JSON.parse(self.zcb)[20]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb20[i]) != 0
         m = to_num(llb9[i]) / to_num(zcb20[i]) * 100
       else
         m = 0
       end
       result << m.round(1)
    end
    return result
  end

  # --- A1-3、现金再投资比率（  >10%比较好 ）---
  # =  经营净现金流llb9 - 红利支付llb16(负数)  /  总资产zcb15 - 流动负债zcb19
  def us_cash_re_investment_ratio
    # 数据提取
    llb9 = JSON.parse(self.llb)[9]
    llb16 = JSON.parse(self.llb)[16]
    zcb15 = JSON.parse(self.zcb)[15]
    zcb19 = JSON.parse(self.zcb)[19]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb15[i]) - to_num(zcb19[i]) != 0
         m = (to_num(llb9[i]) + to_num(llb16[i])) / (to_num(zcb15[i]) - to_num(zcb19[i])) * 100
       else
         m = 0
       end
       result << m.round(1)
    end
    return result
  end

  # --- A2-1、现金与约当现金占总资产比率 ( 10% - 25% 较好 ) ---
  # =  现金与约当现金 zcb2  /  总资产 zcb15
  def us_cash_and_cash_equivalents_ratio
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
       result << m.round(1)
    end
    return result
  end

  # --- A2-2、应收账款占总资产比率 ---
  # =  应收账款 zcb4  /  总资产 zcb15
  def us_receivables_ratio
    # 数据提取
    zcb4 = JSON.parse(self.zcb)[4]
    zcb15 = JSON.parse(self.zcb)[15]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb15[i]) != 0
         m = to_num(zcb4[i]) / to_num(zcb15[i]) * 100
       else
         m = 0
       end
       result << m.round(1)
    end
    return result
  end

  # --- A2-3、存货占总资产比率 ---
  # =  存货 zcb5  /  总资产 zcb15
  def us_inventory_ratio
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
       result << m.round(1)
    end
    return result
  end

  # --- A2-4、流动资产占总资产比率 ---
  # =  流动资产 zcb7  /  总资产 zcb15
  def us_current_assets_ratio
    # 数据提取
    zcb7 = JSON.parse(self.zcb)[7]
    zcb15 = JSON.parse(self.zcb)[15]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb15[i]) != 0
         m = to_num(zcb7[i]) / to_num(zcb15[i]) * 100
       else
         m = 0
       end
       result << m.round(1)
    end
    return result
  end

  # --- A2-5、应付账款占总资产比率 ---
  # =  应付账款 zcb17  /  总资产 zcb15
  def us_accounts_payable_ratio
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
       result << m.round(1)
    end
    return result
  end

  # --- A2-6、流动负债占总资产比率 ---
  # =  流动负债 zcb20  /  总资产 zcb15
  def us_current_liabilities_ratio
    # 数据提取
    zcb20 = JSON.parse(self.zcb)[20]
    zcb15 = JSON.parse(self.zcb)[15]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb15[i]) != 0
         m = to_num(zcb20[i]) / to_num(zcb15[i]) * 100
       else
         m = 0
       end
       result << m.round(1)
    end
    return result
  end

  # --- A2-7、长期负债占总资产比率 ---
  # =  长期负债 zcb21 + 其他负债 zcb22  /  总资产 zcb15
  def us_long_term_liability_ratio
    # 数据提取
    zcb21 = JSON.parse(self.zcb)[21]
    zcb22 = JSON.parse(self.zcb)[22]
    zcb15 = JSON.parse(self.zcb)[15]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb15[i]) != 0
         m = (to_num(zcb21[i]) + to_num(zcb22[i])) / to_num(zcb15[i]) * 100
       else
         m = 0
       end
       result << m.round(1)
    end
    return result
  end

  # --- A2-8、股东权益占总资产比率 ---
  # =  股东权益 zcb36  /  总资产 zcb15
  def us_shareholders_equity_ratio
    # 数据提取
    zcb36 = JSON.parse(self.zcb)[36]
    zcb15 = JSON.parse(self.zcb)[15]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb15[i]) != 0
         m = to_num(zcb36[i]) / to_num(zcb15[i]) * 100
       else
         m = 0
       end
       result << m.round(1)
    end
    return result
  end

  # --- A3-1、应收账款周转率 ---
  # =  营业收入  lrb1  /  应收账款 zcb4
  def us_accounts_receivable_turnover_ratio
    # 数据提取
    lrb1 = JSON.parse(self.lrb)[1]
    zcb4 = JSON.parse(self.zcb)[4]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb4[i]) != 0
         m = to_num(lrb1[i]) / to_num(zcb4[i])
       else
         m = 0
       end
       result << m.round(1)
    end
    return result
  end

  # --- A3-2、存货周转率 ---
  # =  营业成本  lrb2  /  存货 zcb5
  def us_inventory_turnover_ratio
    # 数据提取
    lrb2 = JSON.parse(self.lrb)[2]
    zcb5 = JSON.parse(self.zcb)[5]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb5[i]) != 0
         m = to_num(lrb2[i]) / to_num(zcb5[i])
       else
         m = 0
       end
       result << m.round(1)
    end
    return result
  end

  # --- A3-3、固定资产周转率(不动产/厂房及设备周转率) ---
  # =  营业收入  lrb1  /  不动产/厂房及设备 zcb9
  def us_fixed_asset_turnover_ratio
    # 数据提取
    lrb1 = JSON.parse(self.lrb)[1]
    zcb9 = JSON.parse(self.zcb)[9]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb9[i]) != 0
         m = to_num(lrb1[i]) / to_num(zcb9[i])
       else
         m = 0
       end
       result << m.round(1)
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
       result << m.round(1)
    end
    return result
  end

  # --- C1、营业毛利率 ---
  # =  营业毛利率 = 毛利 lrb3 / 营业收入lrb1
  def us_operating_margin_ratio
    # 数据提取
    lrb3 = JSON.parse(self.lrb)[3]
    lrb1 = JSON.parse(self.lrb)[1]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(lrb1[i]) != 0
         m = to_num(lrb3[i]) / to_num(lrb1[i]) * 100
       else
         m = 0
       end
       result << m.round(1)
    end
    return result
  end

  # --- C2、营业利益率 ---
  # =  营业利益率 = 营业收入或亏损 lrb10 / 营业收入lrb1
  def us_business_profitability_ratio
    # 数据提取
    lrb10 = JSON.parse(self.lrb)[10]
    lrb1 = JSON.parse(self.lrb)[1]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(lrb1[i]) != 0
         m = to_num(lrb10[i]) / to_num(lrb1[i]) * 100
       else
         m = 0
       end
       result << m.round(1)
    end
    return result
  end

  # --- C3、经营安全边际率 ---
  # =  营业收入或亏损 lrb10 / 毛利 lrb3
  def us_operating_margin_of_safety_ratio
    # 数据提取
    lrb10 = JSON.parse(self.lrb)[10]
    lrb3 = JSON.parse(self.lrb)[3]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(lrb3[i]) != 0
         m = to_num(lrb10[i]) / to_num(lrb3[i]) * 100
       else
         m = 0
       end
       result << m.round(1)
    end
    return result
  end

  # --- C4、净利率 ---
  # =  净利率 = 净收入 lrb25 / 营业收入lrb1
  def us_net_profit_margin_ratio
    # 数据提取
    lrb25 = JSON.parse(self.lrb)[25]
    lrb1 = JSON.parse(self.lrb)[1]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(lrb1[i]) != 0
         m = to_num(lrb25[i]) / to_num(lrb1[i]) * 100
       else
         m = 0
       end
       result << m.round(1)
    end
    return result
  end

  # --- C5、每股盈余 ---
  # =  每股收益 = 适用于普通股的净收入 lrb27 / 普通股 zcb31
  def us_earnings_per_share
    # 数据提取
    lrb27 = JSON.parse(self.lrb)[27]
    zcb31 = JSON.parse(self.zcb)[31]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb31[i]) != 0
         m = to_num(lrb27[i]) / to_num(zcb31[i]) / 10
       else
         m = 0
       end
       result << m.round(1)
    end
    return result
  end

  # --- C5-1、税后净利(百万元) ---
  # =  净利润 lrb25
  def us_after_tax_profit
    # 数据提取
    lrb25 = JSON.parse(self.lrb)[25]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(lrb25[i]) != 0
         m = to_num(lrb25[i]) / 1000
       else
         m = 0
       end
       result << m.round(0)
    end
    return result
  end

  # --- C6、股东权益报酬率 ---
  # =  净利润 lrb25 / 总股东权益 zcb36
  def us_roe_ratio
    # 数据提取
    lrb25 = JSON.parse(self.lrb)[25]
    zcb36 = JSON.parse(self.zcb)[36]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb36[i]) != 0
         m = to_num(lrb25[i]) / to_num(zcb36[i]) * 100
       else
         m = 0
       end
       result << m.round(1)
    end
    return result
  end

  # --- D1、负债占资产比率 ---
  # =  总负债 zcb26 / 总资产 zcb15
  def us_debt_asset_ratio
    # 数据提取
    zcb26 = JSON.parse(self.zcb)[26]
    zcb15 = JSON.parse(self.zcb)[15]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb15[i]) != 0
         m = to_num(zcb26[i]) / to_num(zcb15[i]) * 100
       else
         m = 0
       end
       result << m.round(1)
    end
    return result
  end

  # --- D2、长期负债占不动产/厂房及设备比率 ---
  # =  (长期负债 zcb21 + 股东权益 zcb36) / 不动产/厂房及设备 zcb9
  def us_long_term_funds_for_fixed_assets_ratio
    # 数据提取
    zcb21 = JSON.parse(self.zcb)[21]
    zcb36 = JSON.parse(self.zcb)[36]
    zcb9 = JSON.parse(self.zcb)[9]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb9[i]) != 0
         m = (to_num(zcb21[i]) + to_num(zcb36[i])) / to_num(zcb9[i]) * 100
       else
         m = 0
       end
       result << m.round(1)
    end
    return result
  end

  # --- E1、流动比率 ---
  # =  流动比率 = 流动资产 zcb7 / 流动负债 zcb20
  def us_current_ratio
    # 数据提取
    zcb7 = JSON.parse(self.zcb)[7]
    zcb20 = JSON.parse(self.zcb)[20]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb20[i]) != 0
         m = to_num(zcb7[i]) / to_num(zcb20[i]) * 100
       else
         m = 0
       end
       result << m.round(0)
    end
    return result
  end

  # --- E2、速动比率 ---
  # =  流动比率 = (流动资产 zcb7 - 存货 zcb5) / 流动负债 zcb20
  def us_quick_ratio
    # 数据提取
    zcb7 = JSON.parse(self.zcb)[7]
    zcb5 = JSON.parse(self.zcb)[5]
    zcb20 = JSON.parse(self.zcb)[20]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb20[i]) != 0
         m = (to_num(zcb7[i]) - to_num(zcb5[i])) / to_num(zcb20[i]) * 100
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
         m = to_num(llb9[i]) / 1000
       else
         m = 0
       end
       result << m.round(0)
    end
    return result
  end

  # --- F2、投资活动现金流量 ---
  # =  投资活动产生现金流量净额 llb14
  def us_net_investment_activities_generated_cash_flow
    # 数据提取
    llb14 = JSON.parse(self.llb)[14]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(llb14[i]) != 0
         m = to_num(llb14[i]) / 1000
       else
         m = 0
       end
       result << m.round(0)
    end
    return result
  end

  # --- F2、筹资活动现金流量(百万元) ---
  # =  筹资活动产生的现金流量净额 llb20
  def us_net_financing_activities_generated_cash_flow
    # 数据提取
    llb20 = JSON.parse(self.llb)[20]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(llb20[i]) != 0
         m = to_num(llb20[i]) / 1000
       else
         m = 0
       end
       result << m.round(0)
    end
    return result
  end

  # --- G-2、分红金额( b.派息 ) ---
  # 分红金额 = 红利支付 llb16 / 普通股数 zcb31
  def us_dividend_amount
    # 数据提取
    llb16 = JSON.parse(self.llb)[16]
    zcb31 = JSON.parse(self.zcb)[31]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(zcb31[i]) != 0
         m = (0 - to_num(llb16[i])) / to_num(zcb31[i])
       else
         m = 0
       end
       result << m.round(1)
    end
    return result
  end

  # --- G-3、分红率 ---
  # = 红利支付 llb16 / 净利润 lrb27
  def us_dividend_rate
    # 数据提取
    llb16 = JSON.parse(self.llb)[16]
    lrb27 = JSON.parse(self.lrb)[27]
    # 运算
     result = []
     (0..4).each do |i|
       if to_num(lrb27[i]) != 0
         m = (0 - to_num(llb16[i])) / to_num(lrb27[i]) * 100
       else
         m = 0
       end
       result << m.round(1)
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
    sd << ["--","--","--","--","--"]                                # 28-现金流量允当比率
    sd << self.us_cash_re_investment_ratio                          # 29-现金再投资比率
    sd << self.us_stock_years                                       # 30-红利发放期
    sd << self.us_dividend_amount                                   # 31-分红金额
    sd << self.us_dividend_rate                                     # 32-分红率
    self.update!(
      :static_data => sd
    )
  end



  # -----------------modal 弹窗数据脚本, 将输出[时间+数据]的格式用于生成图表-----------------

  # 为 modal_data 传入 time 次数
  def modal_time
    array = JSON.parse(self.static_data)[0]
    num_array = array.delete_if {|x| x == "0" }
    if array.blank?
      return 0
    else
      return num_array.size
    end
  end

  # 财报类 时间为按年
  def modal_data(time, data)
    #判断时间,以确定生成的数据长度
    y = JSON.parse(self.static_data)[0][0..time-1]
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




  # ---------------爬取 美股现价 涨跌幅 和 现市盈率----------------

  def us_stock_latest_price_and_PE
    response = RestClient.get "https://www.laohu8.com/hq/s/#{self.symbol}"
    doc = Nokogiri::HTML.parse(response.body)
    result = []

    # 股票现价
    price = doc.css(".current-quote .num").map{ |x| x.text }[0]
    result << price

    # 股票涨幅
    applies = doc.css(".current-quote .num").map{ |x| x.text }[2]
    result << applies

    # 市盈率 PE
    pe = doc.css(".detail tr[3] td[2]").map{ |x| x.text }[0].split(":")[1]
    result << pe

    # 股息率
    gxl = doc.css(".detail tr[3] td[4]").map{ |x| x.text }[0].split(":")[1]
    result << gxl

    return result
  end




  # -----------------------------------数据排序算法脚本(五年平均)-----------------------------------

  # 五年平均 现金流量排序
  def us_cash_order
    array = JSON.parse(self.static_data)[1]
    num_array = array.delete_if {|x| x == 0 }
    if array.blank?
      return 0
    else
      return (array.sum / num_array.size).round(1)
    end
  end

  # 五年平均 毛利率排序
  def us_operating_margin_order
    array = JSON.parse(self.static_data)[14]
    num_array = array.delete_if {|x| x == 0 }
    if array.blank?
      return 0
    else
      return (array.sum / num_array.size).round(1)
    end
  end

  # 五年平均 营业利益率排序
  def us_business_profitability_order
    array = JSON.parse(self.static_data)[15]
    num_array = array.delete_if {|x| x == 0 }
    if array.blank?
      return 0
    else
      return (array.sum / num_array.size).round(1)
    end
  end

  # 五年平均 净利率排序
  def us_net_profit_margin_order
    array = JSON.parse(self.static_data)[17]
    num_array = array.delete_if {|x| x == 0 }
    if array.blank?
      return 0
    else
      return (array.sum / num_array.size).round(1)
    end
  end

  #股五年平均 东权益报酬率 RoE 排序
  def us_roe_order
    array = JSON.parse(self.static_data)[13]
    num_array = array.delete_if {|x| x == 0 }
    if array.blank? || self.us_net_profit_margin_order <= 0         #修正掉离谱的大数值
      return 0
    else
      return (array.sum / num_array.size).round(1)
    end
  end

  #五年平均 负债占资本利率排序
  def us_debt_asset_order
    array = JSON.parse(self.static_data)[20]
    num_array = array.delete_if {|x| x == 0 }
    if array.blank?
      return 0
    else
      return (array.sum / num_array.size).round(1)
    end
  end

  #分红率排序
  def us_dividend_rate_order
    data = JSON.parse(self.static_data)[32][0]
    if data != nil
      return data
    else
      return 0
    end
  end






end
