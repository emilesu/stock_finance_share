class Stock < ApplicationRecord

  # 资料验证
  validates_presence_of :symbol, :name, :easy_symbol

  # 与 note 关系
  has_many :notes

  # ---把网址改成股票代码---
  def to_param
    self.easy_symbol
  end

  # ---捞出 所有的行业, 并且去重---
  scope :all_industrys_li, -> { pluck(:industry).uniq }       # pluck 方法捞出指定字段的资料



  # -----------------------------------财报季度数据整理脚本-----------------------------------


  # -----------------------------------报表数据算法脚本-----------------------------------
  # ---------- 原数据解析成(行) -----------

  def zcb_r
    self.zcb.split("\n")
  end

  def lrb_r
    self.lrb.split("\n")
  end

  def llb_r
    self.llb.split("\n")
  end


  # 以 "表 行"为参数,输出最近10年的某个科目数据集合:
  #1 = zcb
  #2 = lrb
  #3 = llb
  def quarter_years(table_r, row)
    #确定使用哪个表, 并切行
    if table_r == 1
      table = self.zcb_r
    elsif table_r == 2
      table = self.lrb_r
    elsif table_r == 3
      table = self.llb_r
    end
    # 提取所属年报位置的 KEY
    quarter_all = []
    table[0].split(",").each do |i|
      quarter_all << i
    end
    year_key = []
    (0..quarter_all.size-1).each do |i|
      if quarter_all[i][6] == "2"
        year_key << i
      end
    end
    #确定行row位,并提取数据
    year_data_array =[]
    r = table[row].split(",")
    year_key.each do |i|
      year_data_array << r[i]
    end
    # 返回最近所有年的年份
    return year_data_array
  end

  # 最近季度与去年同季度
  # 以 "表 行"为参数,输出最近两个季度的某个科目数据集合:
  #1 = zcb
  #2 = lrb
  #3 = llb
  def quarter_recent(table_r, row)
    #确定使用哪个表, 并切行
    if table_r == 1
      table = self.zcb_r
    elsif table_r == 2
      table = self.lrb_r
    elsif table_r == 3
      table = self.llb_r
    end
    # 提取所属季报位置的 KEY
    quarter_key = [1, 5]
    #确定行row位,并提取数据
    recent_data_array =[]
    r = table[row].split(",")
    quarter_key.each do |i|
      recent_data_array << r[i]
    end
    return recent_data_array
  end


# -----------------------------------单项数据算法脚本-----------------------------------
  # --- 函数参数说明 ---
  # time = "10", 回传最近10年年报数据
  # time = "5", 回传最近5年年报数据
  # time = "2", 回传最近季度与去年同季度数据

  # --- A1-1、现金流量比率（  >100%比较好 ）---
  # =  营业活动现金流量llb25  /  流动负债zcb84
  def operating_cash_flow_ratio(time)
    # 数据源
    if time == 10
      llb25 = self.quarter_years(3, 25)[0..9]
      zcb84 = self.quarter_years(1, 84)[0..9]
    elsif time == 5
      llb25 = self.quarter_years(3, 25)[0..4]
      zcb84 = self.quarter_years(1, 84)[0..4]
    elsif time == 2
      llb25 = self.quarter_recent(3, 25)
      zcb84 = self.quarter_recent(1, 84)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      if zcb84[i].to_i != 0
        m = llb25[i].to_f / zcb84[i].to_f * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回现金流量比率
    return result
  end

  # --- A1-2、现金流量允当比率（  >100%比较好 ）---
  # =  最近5年营业活动现金流量llb25  /  最近5年  (  资本支出llb33  + 存货减少额-llb75 + 现金股利llb48   )
  def cash_flow_adequancy_ratio(time)
    # 数据提取 - llb25(营业活动现金流量)\llb33(资本支出)\llb75(存货增加额)\llb48(现金股利)
    llb25 = self.quarter_years(3, 25)
    llb33 = self.quarter_years(3, 33)
    llb75 = self.quarter_years(3, 75)
    llb48 = self.quarter_years(3, 48)
    # 运算
    c1 = []
    c2 = []
    c3 = []
    c4 = []
    (1..llb25.size-4).each do |i|
      c1 << llb25[-i].to_f + llb25[-i-1].to_f + llb25[-i-2].to_f + llb25[-i-3].to_f + llb25[-i-4].to_f
      c2 << llb33[-i].to_f + llb33[-i-1].to_f + llb33[-i-2].to_f + llb33[-i-3].to_f + llb33[-i-4].to_f
      c3 << llb75[-i].to_f + llb75[-i-1].to_f + llb75[-i-2].to_f + llb75[-i-3].to_f + llb75[-i-4].to_f
      c4 << llb48[-i].to_f + llb48[-i-1].to_f + llb48[-i-2].to_f + llb48[-i-3].to_f + llb48[-i-4].to_f
    end
    result = []
    (0..c1.size-1).each do |i|
      if (c2[i] - c3[i] + c4[i]) != 0
        m = c1[i] / (c2[i] - c3[i] + c4[i]) * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回最近5年现现金流量允当比率
    if time == 10
      return result.reverse[0..9]
    elsif time == 5
      return result.reverse[0..4]
    elsif time == 2
      return [0, 0]
    end
  end

  # --- A1-3、现金再投资比率（  >10%比较好 ）---
  # =  营业活动现金流量llb25 - 现金股利llb48  /  固定资产毛额  + 长期投资 + 其他资产 + 营运资金 ==> 分母等同于 资产总额zcb52 - 流动负债zcb84
  def cash_re_investment_ratio(time)
    # 数据源
    if time == 10
      llb25 = self.quarter_years(3, 25)[0..9]
      llb48 = self.quarter_years(3, 48)[0..9]
      zcb52 = self.quarter_years(1, 52)[0..9]
      zcb84 = self.quarter_years(1, 84)[0..9]
    elsif time == 5
      llb25 = self.quarter_years(3, 25)[0..4]
      llb48 = self.quarter_years(3, 48)[0..4]
      zcb52 = self.quarter_years(1, 52)[0..4]
      zcb84 = self.quarter_years(1, 84)[0..4]
    elsif time == 2
      llb25 = self.quarter_recent(3, 25)
      llb48 = self.quarter_recent(3, 48)
      zcb52 = self.quarter_recent(1, 52)
      zcb84 = self.quarter_recent(1, 84)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      if (zcb52[i].to_f - zcb84[i].to_f) != 0
        m = (llb25[i].to_f - llb48[i].to_f) / (zcb52[i].to_f - zcb84[i].to_f) * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回现金再投资比率
    return result
  end

  # --- A2-1、现金与约当现金占总资产比率 ( 10% - 25% 较好 ) ---
  # =  现金与约当现金 zcb1+zcb2+zcb3+zcb4+zcb5  /  总资产 zcb52
  def cash_and_cash_equivalents_ratio(time)
    # 数据源
    if time == 10
      zcb1 = self.quarter_years(1, 1)[0..9]
      zcb2 = self.quarter_years(1, 2)[0..9]
      zcb3 = self.quarter_years(1, 3)[0..9]
      zcb4 = self.quarter_years(1, 4)[0..9]
      zcb5 = self.quarter_years(1, 5)[0..9]
      zcb52 = self.quarter_years(1, 52)[0..9]
    elsif time == 5
      zcb1 = self.quarter_years(1, 1)[0..4]
      zcb2 = self.quarter_years(1, 2)[0..4]
      zcb3 = self.quarter_years(1, 3)[0..4]
      zcb4 = self.quarter_years(1, 4)[0..4]
      zcb5 = self.quarter_years(1, 5)[0..4]
      zcb52 = self.quarter_years(1, 52)[0..4]
    elsif time == 2
      zcb1 = self.quarter_recent(1, 1)
      zcb2 = self.quarter_recent(1, 2)
      zcb3 = self.quarter_recent(1, 3)
      zcb4 = self.quarter_recent(1, 4)
      zcb5 = self.quarter_recent(1, 5)
      zcb52 = self.quarter_recent(1, 52)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      if zcb52[i].to_f != 0
        m = (zcb1[i].to_f + zcb2[i].to_f + zcb3[i].to_f + zcb4[i].to_f + zcb5[i].to_f ) / zcb52[i].to_f * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回现金与约当现金占总资产比率
    return result

  end

  # --- A2-2、应收账款占总资产比率 ---
  # =  应收账款 zcb7  /  总资产 zcb52
  def receivables_ratio(time)
    # 数据源
    if time == 10
      zcb7 = self.quarter_years(1, 7)[0..9]
      zcb52 = self.quarter_years(1, 52)[0..9]
    elsif time == 5
      zcb7 = self.quarter_years(1, 7)[0..4]
      zcb52 = self.quarter_years(1, 52)[0..4]
    elsif time == 2
      zcb7 = self.quarter_recent(1, 7)
      zcb52 = self.quarter_recent(1, 52)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      if zcb52[i].to_f != 0
        m = zcb7[i].to_f / zcb52[i].to_f * 100
      else
        m = 0
      end

      result << m.round(1)
    end
    # 返回应收账款占总资产比率
    return result
  end

  # --- A2-3、存货占总资产比率 ---
  # =  存货 zcb20  /  总资产 zcb52
  def inventory_ratio(time)
    # 数据源
    if time == 10
      zcb20 = self.quarter_years(1, 20)[0..9]
      zcb52 = self.quarter_years(1, 52)[0..9]
    elsif time == 5
      zcb20 = self.quarter_years(1, 20)[0..4]
      zcb52 = self.quarter_years(1, 52)[0..4]
    elsif time == 2
      zcb20 = self.quarter_recent(1, 20)
      zcb52 = self.quarter_recent(1, 52)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      if zcb52[i].to_f != 0
        m = zcb20[i].to_f / zcb52[i].to_f * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回存货占总资产比率
    return result
  end

  # --- A2-4、流动资产占总资产比率 ---
  # =  流动资产 zcb25  /  总资产 zcb52
  def current_assets_ratio(time)
    # 数据源
    if time == 10
      zcb25 = self.quarter_years(1, 25)[0..9]
      zcb52 = self.quarter_years(1, 52)[0..9]
    elsif time == 5
      zcb25 = self.quarter_years(1, 25)[0..4]
      zcb52 = self.quarter_years(1, 52)[0..4]
    elsif time == 2
      zcb25 = self.quarter_recent(1, 25)
      zcb52 = self.quarter_recent(1, 52)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      if zcb52[i].to_f != 0
        m = zcb25[i].to_f / zcb52[i].to_f * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回流动资产占总资产比率
    return result
  end

  # --- A2-5、应付账款占总资产比率 ---
  # =  应付账款 zcb60  /  总资产 zcb52
  def accounts_payable_ratio(time)
    # 数据源
    if time == 10
      zcb60 = self.quarter_years(1, 60)[0..9]
      zcb52 = self.quarter_years(1, 52)[0..9]
    elsif time == 5
      zcb60 = self.quarter_years(1, 60)[0..4]
      zcb52 = self.quarter_years(1, 52)[0..4]
    elsif time == 2
      zcb60 = self.quarter_recent(1, 60)
      zcb52 = self.quarter_recent(1, 52)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      if zcb52[i].to_f != 0
        m = zcb60[i].to_f / zcb52[i].to_f * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回应付账款占总资产比率
    return result
  end

  # --- A2-6、流动负债占总资产比率 ---
  # =  流动负债 zcb84  /  总资产 zcb52
  def current_liabilities_ratio(time)
    # 数据源
    if time == 10
      zcb84 = self.quarter_years(1, 84)[0..9]
      zcb52 = self.quarter_years(1, 52)[0..9]
    elsif time == 5
      zcb84 = self.quarter_years(1, 84)[0..4]
      zcb52 = self.quarter_years(1, 52)[0..4]
    elsif time == 2
      zcb84 = self.quarter_recent(1, 84)
      zcb52 = self.quarter_recent(1, 52)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      if zcb52[i].to_f != 0
        m = zcb84[i].to_f / zcb52[i].to_f * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回流动负债占总资产比率
    return result
  end

  # --- A2-7、长期负债占总资产比率 ---
  # =  非流动负债 zcb93  /  总资产 zcb52
  def long_term_liability_ratio(time)
    # 数据源
    if time == 10
      zcb93 = self.quarter_years(1, 93)[0..9]
      zcb52 = self.quarter_years(1, 52)[0..9]
    elsif time == 5
      zcb93 = self.quarter_years(1, 93)[0..4]
      zcb52 = self.quarter_years(1, 52)[0..4]
    elsif time == 2
      zcb93 = self.quarter_recent(1, 93)
      zcb52 = self.quarter_recent(1, 52)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      if zcb52[i].to_f != 0
        m = zcb93[i].to_f / zcb52[i].to_f * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回长期负债占总资产比率
    return result
  end

  # --- A2-8、股东权益占总资产比率 ---
  # =  股东权益 zcb107  /  总资产 zcb52
  def shareholders_equity_ratio(time)
    # 数据源
    if time == 10
      zcb107 = self.quarter_years(1, 107)[0..9]
      zcb52 = self.quarter_years(1, 52)[0..9]
    elsif time == 5
      zcb107 = self.quarter_years(1, 107)[0..4]
      zcb52 = self.quarter_years(1, 52)[0..4]
    elsif time == 2
      zcb107 = self.quarter_recent(1, 107)
      zcb52 = self.quarter_recent(1, 52)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      if zcb52[i].to_f != 0
        m = zcb107[i].to_f / zcb52[i].to_f * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回股东权益占总资产比率
    return result
  end

  # --- A3-1、应收账款周转率 ---
  # =  营业收入  lrb1  /  应收账款 zcb7
  def accounts_receivable_turnover_ratio(time)
    # 数据源
    if time == 10
      lrb1 = self.quarter_years(2, 1)[0..9]
      zcb7 = self.quarter_years(1, 7)[0..9]
    elsif time == 5
      lrb1 = self.quarter_years(2, 1)[0..4]
      zcb7 = self.quarter_years(1, 7)[0..4]
    elsif time == 2
      lrb1 = self.quarter_recent(2, 1)
      zcb7 = self.quarter_recent(1, 7)
    end
    # 运算 判断分母不能为0
    result = []
    (0..time-1).each do |i|
      if (zcb7[i].to_f + zcb7[i-1].to_f) != 0
        m = lrb1[i].to_f / (zcb7[i].to_f + zcb7[i-1].to_f) * 2
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回应收账款周转率
    return result
  end



  # --- A3-2、存货周转率 ---
  # =  营业成本  lrb9  /  存货 zcb20
  def inventory_turnover_ratio(time)
    # 数据源
    if time == 10
      lrb9 = self.quarter_years(2, 9)[0..9]
      zcb20 = self.quarter_years(1, 20)[0..9]
    elsif time == 5
      lrb9 = self.quarter_years(2, 9)[0..4]
      zcb20 = self.quarter_years(1, 20)[0..4]
    elsif time == 2
      lrb9 = self.quarter_recent(2, 9)
      zcb20 = self.quarter_recent(1, 20)
    end
    # 运算 判断分母不能为0
    result = []
    (0..time-1).each do |i|
      if (zcb20[i].to_f + zcb20[i-1].to_f) != 0
        m = lrb9[i].to_f / (zcb20[i].to_f + zcb20[i-1].to_f) * 2
      else
        m = 0
      end

      result << m.round(1)
    end
    # 返回存货周转率
    return result
  end

  # --- A3-3、固定资产周转率(不动产/厂房及设备周转率) ---
  # =  营业收入  lrb1  /  固定资产 zcb37 + 在建工程 zcb38 + 工程物资 zcb39
  def fixed_asset_turnover_ratio(time)
    # 数据源
    if time == 10
      lrb1 = self.quarter_years(2, 1)[0..9]
      zcb37 = self.quarter_years(1, 37)[0..9]
      zcb38 = self.quarter_years(1, 38)[0..9]
      zcb39 = self.quarter_years(1, 39)[0..9]
    elsif time == 5
      lrb1 = self.quarter_years(2, 1)[0..4]
      zcb37 = self.quarter_years(1, 37)[0..4]
      zcb38 = self.quarter_years(1, 38)[0..4]
      zcb39 = self.quarter_years(1, 39)[0..4]
    elsif time == 2
      lrb1 = self.quarter_recent(2, 1)
      zcb37 = self.quarter_recent(1, 37)
      zcb38 = self.quarter_recent(1, 38)
      zcb39 = self.quarter_recent(1, 39)
    end
    # 运算 判断分母不能为0
    result = []
    (0..time-1).each do |i|
      if ( zcb37[i].to_f + zcb38[i].to_f + zcb38[i].to_f ) != 0
        m = lrb1[i].to_f / ( zcb37[i].to_f + zcb38[i].to_f + zcb38[i].to_f )
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回固定资产周转率
    return result
  end

  # --- A3-4、总资产周转率 ---
  # =  营业收入  lrb1  /  总资产 zcb52
  def total_asset_turnover_ratio(time)
    # 数据源
    if time == 10
      lrb1 = self.quarter_years(2, 1)[0..9]
      zcb52 = self.quarter_years(1, 52)[0..9]
    elsif time == 5
      lrb1 = self.quarter_years(2, 1)[0..4]
      zcb52 = self.quarter_years(1, 52)[0..4]
    elsif time == 2
      lrb1 = self.quarter_recent(2, 1)
      zcb52 = self.quarter_recent(1, 52)
    end
    # 运算 判断分母不能为0
    result = []
    (0..time-1).each do |i|
      if zcb52[i].to_i != 0
        m = lrb1[i].to_f / zcb52[i].to_f
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回总资产周转率
    return result
  end

  # --- C1、营业毛利率 ---
  # =  ( 营业收入  lrb2+3+4+5+6+7 - 营业成本 lrb9+10+11+12+13+14+15+16+17+18+19+20 ) /  营业收入  lrb2+3+4+5+6+7
  def operating_margin_ratio(time)
    # 数据源
    if time == 10
      lrb2 = self.quarter_years(2, 2)[0..9]
      lrb3 = self.quarter_years(2, 3)[0..9]
      lrb4 = self.quarter_years(2, 4)[0..9]
      lrb5 = self.quarter_years(2, 5)[0..9]
      lrb6 = self.quarter_years(2, 6)[0..9]
      lrb7 = self.quarter_years(2, 7)[0..9]
      lrb9 = self.quarter_years(2, 9)[0..9]
      lrb10 = self.quarter_years(2, 10)[0..9]
      lrb11 = self.quarter_years(2, 11)[0..9]
      lrb12 = self.quarter_years(2, 12)[0..9]
      lrb13 = self.quarter_years(2, 13)[0..9]
      lrb14 = self.quarter_years(2, 14)[0..9]
      lrb15 = self.quarter_years(2, 15)[0..9]
      lrb16 = self.quarter_years(2, 16)[0..9]
      lrb17 = self.quarter_years(2, 17)[0..9]
      lrb18 = self.quarter_years(2, 18)[0..9]
      lrb19 = self.quarter_years(2, 19)[0..9]
      lrb20 = self.quarter_years(2, 20)[0..9]
    elsif time == 5
      lrb2 = self.quarter_years(2, 2)[0..4]
      lrb3 = self.quarter_years(2, 3)[0..4]
      lrb4 = self.quarter_years(2, 4)[0..4]
      lrb5 = self.quarter_years(2, 5)[0..4]
      lrb6 = self.quarter_years(2, 6)[0..4]
      lrb7 = self.quarter_years(2, 7)[0..4]
      lrb9 = self.quarter_years(2, 9)[0..4]
      lrb10 = self.quarter_years(2, 10)[0..4]
      lrb11 = self.quarter_years(2, 11)[0..4]
      lrb12 = self.quarter_years(2, 12)[0..4]
      lrb13 = self.quarter_years(2, 13)[0..4]
      lrb14 = self.quarter_years(2, 14)[0..4]
      lrb15 = self.quarter_years(2, 15)[0..4]
      lrb16 = self.quarter_years(2, 16)[0..4]
      lrb17 = self.quarter_years(2, 17)[0..4]
      lrb18 = self.quarter_years(2, 18)[0..4]
      lrb19 = self.quarter_years(2, 19)[0..4]
      lrb20 = self.quarter_years(2, 20)[0..4]
    elsif time == 2
      lrb2 = self.quarter_recent(2, 2)
      lrb3 = self.quarter_recent(2, 3)
      lrb4 = self.quarter_recent(2, 4)
      lrb5 = self.quarter_recent(2, 5)
      lrb6 = self.quarter_recent(2, 6)
      lrb7 = self.quarter_recent(2, 7)
      lrb9 = self.quarter_recent(2, 9)
      lrb10 = self.quarter_recent(2, 10)
      lrb11 = self.quarter_recent(2, 11)
      lrb12 = self.quarter_recent(2, 12)
      lrb13 = self.quarter_recent(2, 13)
      lrb14 = self.quarter_recent(2, 14)
      lrb15 = self.quarter_recent(2, 15)
      lrb16 = self.quarter_recent(2, 16)
      lrb17 = self.quarter_recent(2, 17)
      lrb18 = self.quarter_recent(2, 18)
      lrb19 = self.quarter_recent(2, 19)
      lrb20 = self.quarter_recent(2, 20)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      sr = lrb2[i].to_f + lrb3[i].to_f + lrb4[i].to_f + lrb5[i].to_f + lrb6[i].to_f + lrb7[i].to_f
      cb = lrb9[i].to_f + lrb10[i].to_f + lrb11[i].to_f + lrb12[i].to_f + lrb13[i].to_f + lrb14[i].to_f + lrb15[i].to_f + lrb16[i].to_f + lrb17[i].to_f + lrb18[i].to_f + lrb19[i].to_f + lrb20[i].to_f
      if sr != 0
        m = ( sr - cb ) / sr * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回营业毛利率
    return result
  end

  # --- C2、营业利益率 ---
  # =  营业利润  lrb33  /  营业收入 lrb1
  def business_profitability_ratio(time)
    # 数据源
    if time == 10
      lrb33 = self.quarter_years(2, 33)[0..9]
      lrb1 = self.quarter_years(2, 1)[0..9]
    elsif time == 5
      lrb33 = self.quarter_years(2, 33)[0..4]
      lrb1 = self.quarter_years(2, 1)[0..4]
    elsif time == 2
      lrb33 = self.quarter_recent(2, 33)
      lrb1 = self.quarter_recent(2, 1)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      if lrb1[i].to_f != 0
        m = lrb33[i].to_f / lrb1[i].to_f * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回营业毛利率
    return result
  end

  # --- C3、经营安全边际率 ---
  # =  营业利益率 / 营业毛利率
  def operating_margin_of_safety_ratio(time)
    # 数据源
    lyl = self.business_profitability_ratio(time)
    mll = self.operating_margin_ratio(time)
    # 运算
    result = []
    (0..time-1).each do |i|
      if mll[i] != 0
        m = lyl[i] / mll[i] * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回经营安全边际率
    return result
  end

  # --- C4、净利率 ---
  # =  净利润 lrb40 / 营业收入 lrb1
  def net_profit_margin_ratio(time)
    # 数据源
    if time == 10
      lrb40 = self.quarter_years(2, 40)[0..9]
      lrb1 = self.quarter_years(2, 1)[0..9]
    elsif time == 5
      lrb40 = self.quarter_years(2, 40)[0..4]
      lrb1 = self.quarter_years(2, 1)[0..4]
    elsif time == 2
      lrb40 = self.quarter_recent(2, 40)
      lrb1 = self.quarter_recent(2, 1)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      if lrb1[i].to_f != 0
        m = lrb40[i].to_f / lrb1[i].to_f * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回净利率
    return result
  end

  # --- C5、每股盈余 ---
  # =  基本每股收益 lrb44
  def earnings_per_share(time)
    # 数据源
    if time == 10
      lrb44 = self.quarter_years(2, 44)[0..9]
    elsif time == 5
      lrb44 = self.quarter_years(2, 44)[0..4]
    elsif time == 2
      lrb44 = self.quarter_recent(2, 44)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = lrb44[i].to_f
      result << m.round(1)
    end
    # 返回每股盈余
    return result
  end

  # --- C5-1、税后净利(百万元) ---
  # =  净利润 lrb40
  def after_tax_profit(time)
    # 数据源
    if time == 10
      lrb40 = self.quarter_years(2, 40)[0..9]
    elsif time == 5
      lrb40 = self.quarter_years(2, 40)[0..4]
    elsif time == 2
      lrb40 = self.quarter_recent(2, 40)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = lrb40[i].to_f / 100
      result << m.round(0)
    end
    # 返回每股盈余
    return result
  end

  # --- C6、股东权益报酬率 ---
  # =  归属于母公司所有者的净利润 lrb41 / 归属于母公司股东权益合计 zcb105
  def roe_ratio(time)
    # 数据源
    if time == 10
      lrb41 = self.quarter_years(2, 41)[0..9]
      zcb105 = self.quarter_years(1, 105)[0..9]
    elsif time == 5
      lrb41 = self.quarter_years(2, 41)[0..4]
      zcb105 = self.quarter_years(1, 105)[0..4]
    elsif time == 2
      lrb41 = self.quarter_recent(2, 41)
      zcb105 = self.quarter_recent(1, 105)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      if zcb105[i].to_f != 0
        m = lrb41[i].to_f / zcb105[i].to_f * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回每股盈余
    return result
  end

  # --- D1、负债占资产比率 ---
  # =  总负债 zcb94 / 总资产 zcb52
  def debt_asset_ratio(time)
    # 数据源
    if time == 10
      zcb94 = self.quarter_years(1, 94)[0..9]
      zcb52 = self.quarter_years(1, 52)[0..9]
    elsif time == 5
      zcb94 = self.quarter_years(1, 94)[0..4]
      zcb52 = self.quarter_years(1, 52)[0..4]
    elsif time == 2
      zcb94 = self.quarter_recent(1, 94)
      zcb52 = self.quarter_recent(1, 52)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      if zcb52[i].to_f != 0
        m = zcb94[i].to_f / zcb52[i].to_f * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回负债占资产比率
    return result
  end

  # --- D2、长期负债占不动产/厂房及设备比率 ---
  # =  (长期负债 zcb93 + 股东权益 zcb107) / 固定资产 zcb37 + 在建工程 zcb38 + 工程物资 zcb39
  def long_term_funds_for_fixed_assets_ratio(time)
    # 数据源
    if time == 10
      zcb93 = self.quarter_years(1, 93)[0..9]
      zcb107 = self.quarter_years(1, 107)[0..9]
      zcb37 = self.quarter_years(1, 37)[0..9]
      zcb38 = self.quarter_years(1, 38)[0..9]
      zcb39 = self.quarter_years(1, 39)[0..9]
    elsif time == 5
      zcb93 = self.quarter_years(1, 93)[0..4]
      zcb107 = self.quarter_years(1, 107)[0..4]
      zcb37 = self.quarter_years(1, 37)[0..4]
      zcb38 = self.quarter_years(1, 38)[0..4]
      zcb39 = self.quarter_years(1, 39)[0..4]
    elsif time == 2
      zcb93 = self.quarter_recent(1, 93)
      zcb107 = self.quarter_recent(1, 107)
      zcb37 = self.quarter_recent(1, 37)
      zcb38 = self.quarter_recent(1, 38)
      zcb39 = self.quarter_recent(1, 39)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      if zcb37[i].to_f + zcb38[i].to_f + zcb38[i].to_f != 0
        m = ( zcb93[i].to_f + zcb107[i].to_f ) / ( zcb37[i].to_f + zcb38[i].to_f + zcb38[i].to_f ) * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 长期资金占不动产/厂房及设备比率
    return result
  end

  # --- E1、流动比率 ---
  # =  流动资产 zcb25 / 流动负债 zcb84
  def current_ratio(time)
    # 数据源
    if time == 10
      zcb25 = self.quarter_years(1, 25)[0..9]
      zcb84 = self.quarter_years(1, 84)[0..9]
    elsif time == 5
      zcb25 = self.quarter_years(1, 25)[0..4]
      zcb84 = self.quarter_years(1, 84)[0..4]
    elsif time == 2
      zcb25 = self.quarter_recent(1, 25)
      zcb84 = self.quarter_recent(1, 84)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      if zcb84[i].to_f != 0
        m = zcb25[i].to_f / zcb84[i].to_f * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 流动比率
    return result
  end

  # --- E2、速动比率 ---
  # =  流动资产 zcb25 - 存货 zcb20 - 预付款项 zcb8 / 流动负债 zcb84
  def quick_ratio(time)
    # 数据源
    if time == 10
      zcb25 = self.quarter_years(1, 25)[0..9]
      zcb20 = self.quarter_years(1, 20)[0..9]
      zcb8 = self.quarter_years(1, 8)[0..9]
      zcb84 = self.quarter_years(1, 84)[0..9]
    elsif time == 5
      zcb25 = self.quarter_years(1, 25)[0..4]
      zcb20 = self.quarter_years(1, 20)[0..4]
      zcb8 = self.quarter_years(1, 8)[0..4]
      zcb84 = self.quarter_years(1, 84)[0..4]
    elsif time == 2
      zcb25 = self.quarter_recent(1, 25)
      zcb20 = self.quarter_recent(1, 20)
      zcb8 = self.quarter_recent(1, 8)
      zcb84 = self.quarter_recent(1, 84)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      if zcb84[i].to_f != 0
        m = ( zcb25[i].to_f - zcb20[i].to_f - zcb8[i].to_f ) / zcb84[i].to_f * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 流动比率
    return result
  end

  # --- F1、经营活动现金流量(百万元) ---
  # =  经营活动产生现金流量净额(万元) llb81
  def net_cash_flow_of_business_activities(time)
    # 数据源
    if time == 10
      llb81 = self.quarter_years(3, 81)[0..9]
    elsif time == 5
      llb81 = self.quarter_years(3, 81)[0..4]
    elsif time == 2
      llb81 = self.quarter_recent(3, 81)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = llb81[i].to_f / 100
      result << m.round(0)
    end
    # 返回经营活动现金流量
    return result
  end

  # --- F2、投资活动现金流量(百万元) ---
  # =  投资活动产生现金流量净额(万元) llb40
  def net_investment_activities_generated_cash_flow(time)
    # 数据源
    if time == 10
      llb40 = self.quarter_years(3, 40)[0..9]
    elsif time == 5
      llb40 = self.quarter_years(3, 40)[0..4]
    elsif time == 2
      llb40 = self.quarter_recent(3, 40)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = llb40[i].to_f / 100
      result << m.round(0)
    end
    # 返回投资活动现金流量
    return result
  end

  # --- F2、筹资活动现金流量(百万元) ---
  # =  筹资活动产生的现金流量净额(万元) llb52
  def net_financing_activities_generated_cash_flow(time)
    # 数据源
    if time == 10
      llb52 = self.quarter_years(3, 52)[0..9]
    elsif time == 5
      llb52 = self.quarter_years(3, 52)[0..4]
    elsif time == 2
      llb52 = self.quarter_recent(3, 52)
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = llb52[i].to_f / 100
      result << m.round(0)
    end
    # 返回筹资活动现金流量
    return result
  end

  # --- G、分红配股 ---
  # 数据处理 提取格式 [[a.分红年份, b.派息, c.派发日], [a.分红年份, b.派息, c.派发日], ....]

  # --- G-1、红利发放日( c.派发日 ) ---
  def dividend_date(time)
    # 运算
    result = []
    (0..time-1).each do |i|
      m = JSON.parse(self.dividends)[i][2]
      result << m
    end
    # 红利发放日
    return result
  end

  # --- G-2、分红金额( b.派息 ) ---
  def dividend_amount(time)
    # 运算
    result = []
    (0..time-1).each do |i|
      m = JSON.parse(self.dividends)[i][1]
      result << m.to_f
    end
    # 红利发放日
    return result
  end

  # --- G-3、分红率 ---
  # = 分红总额 / 属总公司净利率  =  ( 分红金额 b * 总股本 zcb95 ) / 10  / (所属年度)归属于母公司所有者的净利润 lrb41
  def dividend_rate(time)
    # 数据源
    place_data = []                                               #因为有可能会出现 分红表数据 和 报表数据 年份不一致的情况(今年的分红要以去年数据为基数 或 某年不分红), 所以在此要定位出分红年份
    (0..JSON.parse(self.dividends).size - 1).each do |i|
      target_year = JSON.parse(self.dividends)[i][0]                        #分红年份
      year_data = self.quarter_years(1, 0).map{ |i| i[0..3] }               #报表数据整理出的数组
      place = year_data.index(target_year)                                  #返回对应分红表第一个,在报表数组中所处的的位置
      place_data << place
    end

    amount = self.dividend_amount(time)
    zcb95 = []
    lrb41 = []
    place_data.each do |i|
      if i != nil
        zcb95 << self.quarter_years(1, 95)[i-1]
        lrb41 << self.quarter_years(2, 41)[i]
      end
    end

    # 运算
    result = []
    (0..lrb41.size-1).each do |i|
      if lrb41[i].to_f != 0
        m = amount[i].to_f * zcb95[i].to_f / 10 / lrb41[i].to_f * 100
      else
        m = 0
      end
      result << m.round(1)
    end
    # 返回 红利发放日
    if time == 10
      return result[0..9]
    elsif time == 5
      return result[0..4]
    end
  end

  # --- G-4、股息率 ---
  # = 每股分红金额 / 当前股票价格
  def the_dividend_yield
    dividend = JSON.parse(self.dividends)[0][1].to_f / 10
    price = self.stock_latest_price_and_PE[0].to_f
    result = (dividend / price * 100).round(1)
    # 返回 股息率
    return result
  end


# -----------------------------------数据排序算法脚本(五年平均)-----------------------------------

  # 五年平均 现金流量排序
  def cash_order
    array = JSON.parse(self.static_data_5)[1]
    num_array = []
    array.each do |i|
      if i.to_s != "NaN" && i.to_s != "Infinity" && i.to_s != "-Infinity" && i.class == Float                                         # 判断是否是数字, 防止出现分母是0导致的"Infinity"错误
        num_array << i
      end
    end
    if num_array.blank?
      return 0
    else
      return (num_array.sum / num_array.size).round(1)
    end
  end

  # 五年平均 毛利率排序
  def operating_margin_order
    array = JSON.parse(self.static_data_5)[14]
    num_array = []
    array.each do |i|
      if i.to_s != "NaN" && i.to_s != "Infinity" && i.to_s != "-Infinity" && i.class == Float                                         # 判断是否是数字, 防止出现分母是0导致的"Infinity"错误
        num_array << i
      end
    end
    if num_array.blank?
      return 0
    else
      return (num_array.sum / num_array.size).round(1)
    end
  end

  # 五年平均 营业利益率排序
  def business_profitability_order
    array = JSON.parse(self.static_data_5)[15]
    num_array = []
    array.each do |i|
      if i.to_s != "NaN" && i.to_s != "Infinity" && i.to_s != "-Infinity" && i.class == Float                                         # 判断是否是数字, 防止出现分母是0导致的"Infinity"错误
        num_array << i
      end
    end
    if num_array.blank?
      return 0
    else
      return (num_array.sum / num_array.size).round(1)
    end
  end

  # 五年平均 净利率排序
  def net_profit_margin_order
    array = JSON.parse(self.static_data_5)[17]
    num_array = []
    array.each do |i|
      if i.to_s != "NaN" && i.to_s != "Infinity" && i.to_s != "-Infinity" && i.class == Float                                         # 判断是否是数字, 防止出现分母是0导致的"Infinity"错误
        num_array << i
      end
    end
    if num_array.blank?
      return 0
    else
      return (num_array.sum / num_array.size).round(1)
    end
  end

  #股五年平均 东权益报酬率 RoE 排序
  def roe_order
    array = JSON.parse(self.static_data_5)[13]
    num_array = []
    array.each do |i|
      if i.to_s != "NaN" && i.to_s != "Infinity" && i.to_s != "-Infinity" && i.class == Float                                         # 判断是否是数字, 防止出现分母是0导致的"Infinity"错误
        num_array << i
      end
    end
    if num_array.blank?
      return 0
    else
      return (num_array.sum / num_array.size).round(1)
    end
  end

  #五年平均 负债占资本利率排序
  def debt_asset_order
    array = JSON.parse(self.static_data_5)[20]
    num_array = []
    array.each do |i|
      if i.to_s != "NaN" && i.to_s != "Infinity" && i.to_s != "-Infinity" && i.class == Float                                         # 判断是否是数字, 防止出现分母是0导致的"Infinity"错误
        num_array << i
      end
    end
    if num_array.blank?
      return 0
    else
      return (num_array.sum / num_array.size).round(1)
    end
  end

  #分红率排序
  def dividend_rate_order
    data = self.dividend_rate(5)[0]
    if data != nil
      return data
    else
      return 0
    end
  end



  # -----------------modal 弹窗数据脚本, 将输出[时间+数据]的格式用于生成图表-----------------

  # 财报类 时间为按年
  def modal_data(time, data)
    #判断时间,以确定生成的数据长度
    if time == 10
      y = JSON.parse(self.static_data_10)[0][0..9]
    elsif time == 5
      y = JSON.parse(self.static_data_5)[0][0..4]
    elsif time == 2
      y = JSON.parse(self.static_data_2)[0]
    end
    #与日期对应的数据,生成具体的数据
    m = data
    # 运算
    result = []
    (0..time-1).each do |i|
      main_y = y[i].to_i
      data = [main_y, m[i]]
      result << data
    end
    # 返回 modal 数据
    return result
  end

  # 分红类 时间为按红利发放日
  def modal_dividends_data(time, data)
    #判断时间,以确定生成的数据长度
    if time == 10
      y = JSON.parse(self.static_data_10)[30][0..9]
    elsif time == 5
      y = JSON.parse(self.static_data_5)[30][0..4]
    end
    #与日期对应的数据,生成具体的数据
    m = data
    # 运算
    result = []
    (0..time-1).each do |i|
      main_y = y[i].to_i
      data = [main_y, m[i]]
      result << data
    end
    # 返回 modal 数据
    return result
  end



  # ---------------爬取 股票现价 涨跌幅 和 现市盈率----------------

  def stock_latest_price_and_PE
    response = RestClient.get "http://gu.qq.com/#{self.symbol}/gp"
    doc = Nokogiri::HTML.parse(response.body)
    result = []

    # 股票现价
    price = doc.css(".data").map{ |x| x.text }[0]
    result << price

    # 股票涨幅
    applies = doc.css(".item-2 .fr").map{ |x| x.text }[0]
    result << applies

    # 市盈率 PE
    pe = doc.css(".clear[2] li[4]").map{ |x| x.text }[2][4..-1]
    result << pe

    return result
  end



  # ---------------------- 数据静态会保存 ----------------------

  def static_data

    # static_data_10
    sd_10 = []
    sd_10 << self.quarter_years(1, 0)[0..9]                               # 0-年报年度
    sd_10 << self.cash_and_cash_equivalents_ratio(10)                     # 1-现金与约当现金
    sd_10 << self.receivables_ratio(10)                                   # 2-应收账款
    sd_10 << self.inventory_ratio(10)                                     # 3-存货
    sd_10 << self.current_assets_ratio(10)                                # 4-流动资产
    sd_10 << self.accounts_payable_ratio(10)                              # 5-应付账款
    sd_10 << self.current_liabilities_ratio(10)                           # 6-流动负债
    sd_10 << self.long_term_liability_ratio(10)                           # 7-长期负债
    sd_10 << self.shareholders_equity_ratio(10)                           # 8-股东权益
    sd_10 << self.accounts_receivable_turnover_ratio(10)                  # 9-应收账款周转率
    sd_10 << self.inventory_turnover_ratio(10)                            # 10-存货周转率
    sd_10 << self.fixed_asset_turnover_ratio(10)                          # 11-不动产/厂房及设备周转率
    sd_10 << self.total_asset_turnover_ratio(10)                          # 12-总资产周转率
    sd_10 << self.roe_ratio(10)                                           # 13-股东权益报酬率 ROE
    sd_10 << self.operating_margin_ratio(10)                              # 14-营业毛利率
    sd_10 << self.business_profitability_ratio(10)                        # 15-营业利益率
    sd_10 << self.operating_margin_of_safety_ratio(10)                    # 16-经营安全边际率
    sd_10 << self.net_profit_margin_ratio(10)                             # 17-净利率
    sd_10 << self.earnings_per_share(10)                                  # 18-每股盈余
    sd_10 << self.after_tax_profit(10)                                    # 19-税后净利
    sd_10 << self.debt_asset_ratio(10)                                    # 20-负债占资产比率
    sd_10 << self.long_term_funds_for_fixed_assets_ratio(10)              # 21-长期负债占不动产/厂房及设备比率
    sd_10 << self.current_ratio(10)                                       # 22-流动比率
    sd_10 << self.quick_ratio(10)                                         # 23-速动比率
    sd_10 << self.net_cash_flow_of_business_activities(10)                # 24-经营活动现金流量(百万元)
    sd_10 << self.net_investment_activities_generated_cash_flow(10)       # 25-投资活动现金流量(百万元)
    sd_10 << self.net_financing_activities_generated_cash_flow(10)        # 26-筹资活动现金流量(百万元)
    sd_10 << self.operating_cash_flow_ratio(10)                           # 27-现金流量比率
    sd_10 << self.cash_flow_adequancy_ratio(10)                           # 28-现金流量允当比率
    sd_10 << self.cash_re_investment_ratio(10)                            # 29-现金再投资比率
    sd_10 << self.dividend_date(10)                                       # 30-红利发放日
    sd_10 << self.dividend_amount(10)                                     # 31-分红金额
    sd_10 << self.dividend_rate(10)                                       # 32-分红率
    self.update!(
      :static_data_10 => sd_10
    )

    # static_data_5
    sd_5 = []
    sd_5 << self.quarter_years(1, 0)[0..4]                              # 0-年报年度
    sd_5 << self.cash_and_cash_equivalents_ratio(5)                     # 1-现金与约当现金
    sd_5 << self.receivables_ratio(5)                                   # 2-应收账款
    sd_5 << self.inventory_ratio(5)                                     # 3-存货
    sd_5 << self.current_assets_ratio(5)                                # 4-流动资产
    sd_5 << self.accounts_payable_ratio(5)                              # 5-应付账款
    sd_5 << self.current_liabilities_ratio(5)                           # 6-流动负债
    sd_5 << self.long_term_liability_ratio(5)                           # 7-长期负债
    sd_5 << self.shareholders_equity_ratio(5)                           # 8-股东权益
    sd_5 << self.accounts_receivable_turnover_ratio(5)                  # 9-应收账款周转率
    sd_5 << self.inventory_turnover_ratio(5)                            # 10-存货周转率
    sd_5 << self.fixed_asset_turnover_ratio(5)                          # 11-不动产/厂房及设备周转率
    sd_5 << self.total_asset_turnover_ratio(5)                          # 12-总资产周转率
    sd_5 << self.roe_ratio(5)                                           # 13-股东权益报酬率 ROE
    sd_5 << self.operating_margin_ratio(5)                              # 14-营业毛利率
    sd_5 << self.business_profitability_ratio(5)                        # 15-营业利益率
    sd_5 << self.operating_margin_of_safety_ratio(5)                    # 16-经营安全边际率
    sd_5 << self.net_profit_margin_ratio(5)                             # 17-净利率
    sd_5 << self.earnings_per_share(5)                                  # 18-每股盈余
    sd_5 << self.after_tax_profit(5)                                    # 19-税后净利
    sd_5 << self.debt_asset_ratio(5)                                    # 20-负债占资产比率
    sd_5 << self.long_term_funds_for_fixed_assets_ratio(5)              # 21-长期负债占不动产/厂房及设备比率
    sd_5 << self.current_ratio(5)                                       # 22-流动比率
    sd_5 << self.quick_ratio(5)                                         # 23-速动比率
    sd_5 << self.net_cash_flow_of_business_activities(5)                # 24-经营活动现金流量(百万元)
    sd_5 << self.net_investment_activities_generated_cash_flow(5)       # 25-投资活动现金流量(百万元)
    sd_5 << self.net_financing_activities_generated_cash_flow(5)        # 26-筹资活动现金流量(百万元)
    sd_5 << self.operating_cash_flow_ratio(5)                           # 27-现金流量比率
    sd_5 << self.cash_flow_adequancy_ratio(5)                           # 28-现金流量允当比率
    sd_5 << self.cash_re_investment_ratio(5)                            # 29-现金再投资比率
    sd_5 << self.dividend_date(5)                                       # 30-红利发放日
    sd_5 << self.dividend_amount(5)                                     # 31-分红金额
    sd_5 << self.dividend_rate(5)                                       # 32-分红率
    self.update!(
      :static_data_5 => sd_5
    )

    # static_data_2
    sd_2 = []
    sd_2 << self.quarter_recent(1, 0)                                   # 0-年报年度
    sd_2 << self.cash_and_cash_equivalents_ratio(2)                     # 1-现金与约当现金
    sd_2 << self.receivables_ratio(2)                                   # 2-应收账款
    sd_2 << self.inventory_ratio(2)                                     # 3-存货
    sd_2 << self.current_assets_ratio(2)                                # 4-流动资产
    sd_2 << self.accounts_payable_ratio(2)                              # 5-应付账款
    sd_2 << self.current_liabilities_ratio(2)                           # 6-流动负债
    sd_2 << self.long_term_liability_ratio(2)                           # 7-长期负债
    sd_2 << self.shareholders_equity_ratio(2)                           # 8-股东权益
    sd_2 << self.accounts_receivable_turnover_ratio(2)                  # 9-应收账款周转率
    sd_2 << self.inventory_turnover_ratio(2)                            # 10-存货周转率
    sd_2 << self.fixed_asset_turnover_ratio(2)                          # 11-不动产/厂房及设备周转率
    sd_2 << self.total_asset_turnover_ratio(2)                          # 12-总资产周转率
    sd_2 << self.roe_ratio(2)                                           # 13-股东权益报酬率 ROE
    sd_2 << self.operating_margin_ratio(2)                              # 14-营业毛利率
    sd_2 << self.business_profitability_ratio(2)                        # 15-营业利益率
    sd_2 << self.operating_margin_of_safety_ratio(2)                    # 16-经营安全边际率
    sd_2 << self.net_profit_margin_ratio(2)                             # 17-净利率
    sd_2 << self.earnings_per_share(2)                                  # 18-每股盈余
    sd_2 << self.after_tax_profit(2)                                    # 19-税后净利
    sd_2 << self.debt_asset_ratio(2)                                    # 20-负债占资产比率
    sd_2 << self.long_term_funds_for_fixed_assets_ratio(2)              # 21-长期负债占不动产/厂房及设备比率
    sd_2 << self.current_ratio(2)                                       # 22-流动比率
    sd_2 << self.quick_ratio(2)                                         # 23-速动比率
    sd_2 << self.net_cash_flow_of_business_activities(2)                # 24-经营活动现金流量(百万元)
    sd_2 << self.net_investment_activities_generated_cash_flow(2)       # 25-投资活动现金流量(百万元)
    sd_2 << self.net_financing_activities_generated_cash_flow(2)        # 26-筹资活动现金流量(百万元)
    sd_2 << self.operating_cash_flow_ratio(2)                           # 27-现金流量比率
    sd_2 << self.cash_flow_adequancy_ratio(2)                           # 28-现金流量允当比率
    sd_2 << self.cash_re_investment_ratio(2)                            # 29-现金再投资比率
    self.update!(
      :static_data_2 => sd_2
    )

  end

end
