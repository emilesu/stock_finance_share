class Stock < ApplicationRecord

  # ---把网址改成股票代码---
  def to_param
    self.easy_symbol
  end


  # -----------------------------------财报季度数据整理脚本-----------------------------------

  # ---当前 利润表/lrb 财报季度，用于修正数据读取和表格的显示。安装最新财报发布季度来进行设置---
  # ---第一季度：1   第二季度：2    第三季度：3    年报季度：0---
  def quarter_lrb
    col = JSON.parse(self.lrb)[0]
    data = col.split(",")[2]
    if data[6] == "3"
      return 1
    end
    if data[6] == "6"
      return 2
    end
    if data[6] == "9"
      return 3
    end
    if data[6] == "2"
      return 0
    end
  end

  # ---当前 利润表/lrb 财报季度，用于修正数据读取和表格的显示。安装最新财报发布季度来进行设置---
  # ---第一季度：1   第二季度：2    第三季度：3    年报季度：0---
  def quarter_llb
    col = JSON.parse(self.llb)[0]
    data = col.split(",")[2]
    if data[6] == "3"
      return 1
    end
    if data[6] == "6"
      return 2
    end
    if data[6] == "9"
      return 3
    end
    if data[6] == "2"
      return 0
    end
  end

  # ---当前 利润表/lrb 财报季度，用于修正数据读取和表格的显示。安装最新财报发布季度来进行设置---
  # ---第一季度：1   第二季度：2    第三季度：3    年报季度：0---
  def quarter_zcb
    col = JSON.parse(self.zcb)[0]
    data = col.split(",")[2]
    if data[6] == "3"
      return 1
    end
    if data[6] == "6"
      return 2
    end
    if data[6] == "9"
      return 3
    end
    if data[6] == "2"
      return 0
    end
  end

  # ---当前 利润表/lrb 财报季度，用于修正数据读取和表格的显示。安装最新财报发布季度来进行设置---
  # ---第一季度：1   第二季度：2    第三季度：3    年报季度：0---
  def quarter_fzb
    col = JSON.parse(self.fzb)[0]
    data = col.split(",")[2]
    if data[6] == "3"
      return 1
    end
    if data[6] == "6"
      return 2
    end
    if data[6] == "9"
      return 3
    end
    if data[6] == "2"
      return 0
    end
  end

  # ---当前 利润表/lrb 财报季度，用于修正数据读取和表格的显示。安装最新财报发布季度来进行设置---
  # ---第一季度：1   第二季度：2    第三季度：3    年报季度：0---
  def quarter_gdb
    col = JSON.parse(self.gdb)[0]
    data = col.split(",")[2]
    if data[6] == "3"
      return 1
    end
    if data[6] == "6"
      return 2
    end
    if data[6] == "9"
      return 3
    end
    if data[6] == "2"
      return 0
    end
  end




  # -----------------------------------报表数据算法脚本-----------------------------------


  # 十年度 年报年份
  def quarter_years
    # 数据源
    col = JSON.parse(self.lrb)
    # 提取所有报表的季度
    quarter_all = []
    col.each do |i|
      quarter_all << i.split(",")[2]
    end
    # 提取属于年报的年度
    year_all = []
    quarter_all.each do |i|
      if i[6] == "2"
        year_all << i
      end
    end
    # 返回最近所有年的年份
    return year_all
  end

  # 最近季度与去年同季度
  def quarter_recent
    # 数据源
    col = JSON.parse(self.lrb)
    # 提取所有报表的季度
    quarter_all = []
    col.each do |i|
      quarter_all << i.split(",")[2]
    end
    # 提取属于年报的年度
    recent_all = []
    recent_all << quarter_all[0]
    recent_all << quarter_all[4]
    # 返回最近季度与去年同季度
    return recent_all
  end

  # --- 函数参数说明 ---
  # time = "10", 回传最近10年年报数据
  # time = "5", 回传最近5年年报数据
  # time = "2", 回传最近季度与去年同季度数据

  # --- A1-1、现金流量比率（  >100%比较好 ）---
  # =  营业活动现金流量llb27  /  流动负债fzb34
  def operating_cash_flow_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_llb = JSON.parse(self.llb)
    col_fzb = JSON.parse(self.fzb)
    # 数据提取 - 营业活动现金流量
    col_llb_main = []
    col_llb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_llb_main << m[27]
      end
    end
    # 数据提取 - 流动负债
    col_fzb_main = []
    col_fzb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_fzb_main << m[34]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      if col_fzb_main[i].to_i != 0
        m = col_llb_main[i].to_f / col_fzb_main[i].to_f * 100
        result << m.round(2)
      end
    end
    # 返回现金流量比率
    return result
  end

  # --- A1-2、现金流量允当比率（  >100%比较好 ）---
  # =  最近5年营业活动现金流量llb27  /  最近5年  (  资本支出llb35  + 存货增加额-llb77 + 现金股利llb50   )
  def cash_flow_adequancy_ratio(time)
    # 数据源
    if time == 2
      result = nil
    end
    all_years = self.quarter_years
    col_llb = JSON.parse(self.llb).reverse
    # 数据提取 - col_llb_main_1(营业活动现金流量)\col_llb_main_2(资本支出)\col_llb_main_3(存货增加额)\col_llb_main_4(现金股利)
    col_llb_main_1 = []
    col_llb_main_2 = []
    col_llb_main_3 = []
    col_llb_main_4 = []
    col_llb.each do |i|
      m = i.split(",")
      if all_years.include?(m[2])
        col_llb_main_1 << m[27]
        col_llb_main_2 << m[35]
        col_llb_main_3 << m[77]
        col_llb_main_4 << m[50]
      end
    end
    # 运算
    c1 = []
    c2 = []
    c3 = []
    c4 = []
    (1..all_years.count-4).each do |i|
      c1 << col_llb_main_1[-i].to_f + col_llb_main_1[-i-1].to_f + col_llb_main_1[-i-2].to_f + col_llb_main_1[-i-3].to_f + col_llb_main_1[-i-4].to_f
      c2 << col_llb_main_2[-i].to_f + col_llb_main_2[-i-1].to_f + col_llb_main_2[-i-2].to_f + col_llb_main_2[-i-3].to_f + col_llb_main_2[-i-4].to_f
      c3 << col_llb_main_3[-i].to_f + col_llb_main_3[-i-1].to_f + col_llb_main_3[-i-2].to_f + col_llb_main_3[-i-3].to_f + col_llb_main_3[-i-4].to_f
      c4 << col_llb_main_4[-i].to_f + col_llb_main_4[-i-1].to_f + col_llb_main_4[-i-2].to_f + col_llb_main_4[-i-3].to_f + col_llb_main_4[-i-4].to_f
    end
    result = []
    (0..c1.count-1).each do |i|
      m = c1[i] / (c2[i] - c3[i] + c4[i]) * 100
      result << m.round(2)
    end
    # 返回最近5年现现金流量允当比率
    return result[0..time-1]
  end

  # --- A1-3、现金再投资比率（  >10%比较好 ）---
  # =  营业活动现金流量llb27 - 现金股利llb50  /  固定资产毛额  + 长期投资 + 其他资产 + 营运资金 ==> 分母等同于 资产总额zcb54 - 流动负债fzb34
  def cash_re_investment_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_llb = JSON.parse(self.llb)
    col_zcb = JSON.parse(self.zcb)
    col_fzb = JSON.parse(self.fzb)
    # 数据提取 - 营业活动现金流量 和 现金股利
    col_llb_main_1 = []
    col_llb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_llb_main_1 << m[27]
      end
    end
    # 数据提取 - 现金股利
    col_llb_main_2 = []
    col_llb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_llb_main_2 << m[50]
      end
    end
    # 数据提取 - 资产总额
    col_zcb_main = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main << m[54]
      end
    end
    # 数据提取 - 流动负债
    col_fzb_main = []
    col_fzb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_fzb_main << m[34]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = (col_llb_main_1[i].to_f - col_llb_main_2[i].to_f) / (col_zcb_main[i].to_f - col_fzb_main[i].to_f) * 100
      result << m.round(2)
    end
    # 返回现金再投资比率
    return result
  end

  # --- A2-1、现金与约当现金占总资产比率 ( 10% - 25% 较好 ) ---
  # =  现金与约当现金 zcb3+zcb4+zcb5+zcb6+zcb7  /  总资产 zcb54
  def cash_and_cash_equivalents_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_zcb = JSON.parse(self.zcb)
    # 数据提取 - 货币资金
    col_zcb_main_1 = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main_1 << m[3]
      end
    end
    # 数据提取 - 结算备付金
    col_zcb_main_2 = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main_2 << m[4]
      end
    end
    # 数据提取 - 拆出资金
    col_zcb_main_3 = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main_3 << m[5]
      end
    end
    # 数据提取 - 交易性金融资产
    col_zcb_main_4 = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main_4 << m[6]
      end
    end
    # 数据提取 - 衍生金融资产
    col_zcb_main_5 = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main_5 << m[7]
      end
    end
    # 数据提取 - 衍生金融资产
    col_zcb_main_6 = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main_6 << m[54]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = (col_zcb_main_1[i].to_f + col_zcb_main_2[i].to_f + col_zcb_main_3[i].to_f + col_zcb_main_4[i].to_f + col_zcb_main_5[i].to_f ) / (col_zcb_main_6[i].to_f) * 100
      result << m.round(2)
    end
    # 返回现金与约当现金占总资产比率
    return result

  end

  # --- A2-2、应收账款占总资产比率 ---
  # =  应收账款 zcb9  /  总资产 zcb54
  def receivables_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_zcb = JSON.parse(self.zcb)
    # 数据提取 - 应收账款
    col_zcb_main_1 = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main_1 << m[9]
      end
    end
    # 数据提取 - 总资产
    col_zcb_main_2 = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main_2 << m[54]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = col_zcb_main_1[i].to_f / col_zcb_main_2[i].to_f * 100
      result << m.round(2)
    end
    # 返回应收账款占总资产比率
    return result
  end

  # --- A2-3、存货占总资产比率 ---
  # =  存货 zcb22  /  总资产 zcb54
  def inventory_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_zcb = JSON.parse(self.zcb)
    # 数据提取 - 存货
    col_zcb_main_1 = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main_1 << m[22]
      end
    end
    # 数据提取 - 总资产
    col_zcb_main_2 = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main_2 << m[54]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = col_zcb_main_1[i].to_f / col_zcb_main_2[i].to_f * 100
      result << m.round(2)
    end
    # 返回存货占总资产比率
    return result
  end

  # --- A2-4、流动资产占总资产比率 ---
  # =  流动资产 zcb27  /  总资产 zcb54
  def current_assets_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_zcb = JSON.parse(self.zcb)
    # 数据提取 - 流动资产
    col_zcb_main_1 = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main_1 << m[27]
      end
    end
    # 数据提取 - 总资产
    col_zcb_main_2 = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main_2 << m[54]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = col_zcb_main_1[i].to_f / col_zcb_main_2[i].to_f * 100
      result << m.round(2)
    end
    # 返回流动资产占总资产比率
    return result
  end

  # --- A2-5、应付账款占总资产比率 ---
  # =  应付账款 fzb10  /  总资产 zcb54
  def accounts_payable_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_fzb = JSON.parse(self.fzb)
    col_zcb = JSON.parse(self.zcb)
    # 数据提取 - 应付账款
    col_fzb_main = []
    col_fzb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_fzb_main << m[10]
      end
    end
    # 数据提取 - 总资产
    col_zcb_main = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main << m[54]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = col_fzb_main[i].to_f / col_zcb_main[i].to_f * 100
      result << m.round(2)
    end
    # 返回应付账款占总资产比率
    return result
  end

  # --- A2-6、流动负债占总资产比率 ---
  # =  流动负债 fzb34  /  总资产 zcb54
  def current_liabilities_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_fzb = JSON.parse(self.fzb)
    col_zcb = JSON.parse(self.zcb)
    # 数据提取 - 流动负债
    col_fzb_main = []
    col_fzb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_fzb_main << m[34]
      end
    end
    # 数据提取 - 总资产
    col_zcb_main = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main << m[54]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = col_fzb_main[i].to_f / col_zcb_main[i].to_f * 100
      result << m.round(2)
    end
    # 返回流动负债占总资产比率
    return result
  end

  # --- A2-7、长期负债占总资产比率 ---
  # =  长期负债 fzb43  /  总资产 zcb54
  def long_term_liability_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_fzb = JSON.parse(self.fzb)
    col_zcb = JSON.parse(self.zcb)
    # 数据提取 - 长期负债
    col_fzb_main = []
    col_fzb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_fzb_main << m[43]
      end
    end
    # 数据提取 - 总资产
    col_zcb_main = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main << m[54]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = col_fzb_main[i].to_f / col_zcb_main[i].to_f * 100
      result << m.round(2)
    end
    # 返回长期负债占总资产比率
    return result
  end

  # --- A2-8、股东权益占总资产比率 ---
  # =  股东权益 gdb15  /  总资产 zcb54
  def shareholders_equity_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_gdb = JSON.parse(self.gdb)
    col_zcb = JSON.parse(self.zcb)
    # 数据提取 - 股东权益
    col_gdb_main = []
    col_gdb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_gdb_main << m[15]
      end
    end
    # 数据提取 - 总资产
    col_zcb_main = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main << m[54]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = col_gdb_main[i].to_f / col_zcb_main[i].to_f * 100
      result << m.round(2)
    end
    # 返回股东权益占总资产比率
    return result
  end

  # --- A3-1、应收账款周转率 ---
  # =  营业收入  lrb3  /  应收账款 zcb9
  def accounts_receivable_turnover_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_lrb = JSON.parse(self.lrb)
    col_zcb = JSON.parse(self.zcb)
    # 数据提取 - 营业收入
    col_lrb_main = []
    col_lrb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_lrb_main << m[3]
      end
    end
    # 数据提取 - 应收账款
    col_zcb_main = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main << m[9]
      end
    end
    # 运算 判断分母不能为0
    result = []
    (0..time-1).each do |i|
      if col_zcb_main[i].to_i != 0
        m = col_lrb_main[i].to_f / col_zcb_main[i].to_f
        result << m.round(2)
      end
    end
    # 返回应收账款周转率
    return result
  end



  # --- A3-2、存货周转率 ---
  # =  营业成本  lrb11  /  存货 zcb22
  def inventory_turnover_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_lrb = JSON.parse(self.lrb)
    col_zcb = JSON.parse(self.zcb)
    # 数据提取 - 营业成本
    col_lrb_main = []
    col_lrb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_lrb_main << m[11]
      end
    end
    # 数据提取 - 存货
    col_zcb_main = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main << m[22]
      end
    end
    # 运算 判断分母不能为0
    result = []
    (0..time-1).each do |i|
        m = col_lrb_main[i].to_f / col_zcb_main[i].to_f
        result << m.round(2)
    end
    # 返回存货周转率
    return result
  end

  # --- A3-3、固定资产周转率(不动产/厂房及设备周转率) ---
  # =  营业收入  lrb3  /  固定资产 zcb39
  def fixed_asset_turnover_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_lrb = JSON.parse(self.lrb)
    col_zcb = JSON.parse(self.zcb)
    # 数据提取 - 营业收入
    col_lrb_main = []
    col_lrb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_lrb_main << m[3]
      end
    end
    # 数据提取 - 固定资产周转率
    col_zcb_main = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main << m[39]
      end
    end
    # 运算 判断分母不能为0
    result = []
    (0..time-1).each do |i|
      if col_zcb_main[i].to_i != 0
        m = col_lrb_main[i].to_f / col_zcb_main[i].to_f
        result << m.round(2)
      end
    end
    # 返回固定资产周转率
    return result
  end

  # --- A3-4、总资产周转率 ---
  # =  营业收入  lrb3  /  总资产 zcb54
  def total_asset_turnover_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_lrb = JSON.parse(self.lrb)
    col_zcb = JSON.parse(self.zcb)
    # 数据提取 - 营业收入
    col_lrb_main = []
    col_lrb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_lrb_main << m[3]
      end
    end
    # 数据提取 - 总资产
    col_zcb_main = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main << m[54]
      end
    end
    # 运算 判断分母不能为0
    result = []
    (0..time-1).each do |i|
      if col_zcb_main[i].to_i != 0
        m = col_lrb_main[i].to_f / col_zcb_main[i].to_f
        result << m.round(2)
      end
    end
    # 返回总资产周转率
    return result
  end

  # --- C1、营业毛利率 ---
  # =  营业利润  lrb35  /  营业收入 lrb3
  def operating_margin_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_lrb = JSON.parse(self.lrb)
    # 数据提取 - 营业利润
    col_lrb_main_1 = []
    col_lrb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_lrb_main_1 << m[35]
      end
    end
    # 数据提取 - 营业收入
    col_lrb_main_2 = []
    col_lrb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_lrb_main_2 << m[3]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = col_lrb_main_1[i].to_f / col_lrb_main_2[i].to_f * 100
      result << m.round(2)
    end
    # 返回营业毛利率
    return result
  end

  # --- C2、营业利益率 ---
  # =  营业利益  lrb35 - lrb10 + lrb11 / 营业收入 lrb3
  def business_profitability_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_lrb = JSON.parse(self.lrb)
    # 数据提取 - 营业利润
    col_lrb_main_1 = []
    col_lrb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_lrb_main_1 << m[35]
      end
    end
    # 数据提取 - 营业总成本
    col_lrb_main_2 = []
    col_lrb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_lrb_main_2 << m[10]
      end
    end
    # 数据提取 - 营业成本
    col_lrb_main_3 = []
    col_lrb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_lrb_main_3 << m[11]
      end
    end
    # 数据提取 - 营业收入
    col_lrb_main_4 = []
    col_lrb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_lrb_main_4 << m[3]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = ( col_lrb_main_1[i].to_f - col_lrb_main_2[i].to_f + col_lrb_main_3[i].to_f ) / col_lrb_main_4[i].to_f * 100
      result << m.round(2)
    end
    # 返回营业利益率
    return result
  end

  # --- C3、经营安全边际率 ---
  # =  营业利益  lrb35 - lrb10 + lrb11 / 营业利润 lrb35
  def operating_margin_of_safety_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_lrb = JSON.parse(self.lrb)
    # 数据提取 - 营业利润
    col_lrb_main_1 = []
    col_lrb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_lrb_main_1 << m[35]
      end
    end
    # 数据提取 - 营业总成本
    col_lrb_main_2 = []
    col_lrb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_lrb_main_2 << m[10]
      end
    end
    # 数据提取 - 营业成本
    col_lrb_main_3 = []
    col_lrb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_lrb_main_3 << m[11]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      x1 = col_lrb_main_1[i].to_f - col_lrb_main_2[i].to_f + col_lrb_main_3[i].to_f
      x2 = col_lrb_main_1[i].to_f
      if x1 < 0 && x2 < 0
        result << "严重风险"
      else
        m = x1 / x2 * 100
        result << m.round(2)
      end
    end
    # 返回经营安全边际率
    return result
  end

  # --- C4、净利率 ---
  # =  净利润 lrb42 / 营业收入 lrb3
  def net_profit_margin_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_lrb = JSON.parse(self.lrb)
    # 数据提取 - 净利润
    col_lrb_main_1 = []
    col_lrb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_lrb_main_1 << m[42]
      end
    end
    # 数据提取 - 营业收入
    col_lrb_main_2 = []
    col_lrb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_lrb_main_2 << m[3]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = col_lrb_main_1[i].to_f / col_lrb_main_2[i].to_f * 100
      result << m.round(2)
    end
    # 返回净利率
    return result
  end

  # --- C5、每股盈余 ---
  # =  净利润 lrb42 / 总股本 gdb4
  def earnings_per_share(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_lrb = JSON.parse(self.lrb)
    col_gdb = JSON.parse(self.gdb)
    # 数据提取 - 净利润
    col_lrb_main = []
    col_lrb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_lrb_main << m[42]
      end
    end
    # 数据提取 - 营业收入
    col_gdb_main = []
    col_gdb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_gdb_main << m[3]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = col_lrb_main[i].to_f / col_gdb_main[i].to_f
      result << m.round(2)
    end
    # 返回每股盈余
    return result
  end

  # --- C5-1、税后净利(百万元) ---
  # =  净利润 lrb42
  def after_tax_profit(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_lrb = JSON.parse(self.lrb)
    # 数据提取 - 净利润
    col_lrb_main = []
    col_lrb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_lrb_main << m[42]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = col_lrb_main[i].to_f / 100
      result << m.round(0)
    end
    # 返回每股盈余
    return result
  end

  # --- C6、股东权益报酬率 ---
  # =  净利润 lrb42 / 股东权益 gdb15
  def roe_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_lrb = JSON.parse(self.lrb)
    col_gdb = JSON.parse(self.gdb)
    # 数据提取 - 净利润
    col_lrb_main = []
    col_lrb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_lrb_main << m[42]
      end
    end
    # 数据提取 - 营业收入
    col_gdb_main = []
    col_gdb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_gdb_main << m[15]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = col_lrb_main[i].to_f / col_gdb_main[i].to_f * 100
      result << m.round(2)
    end
    # 返回每股盈余
    return result
  end

  # --- D1、负债占资产比率 ---
  # =  总负责 fzb44 / 总资产 zcb54
  def debt_asset_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_fzb = JSON.parse(self.fzb)
    col_zcb = JSON.parse(self.zcb)
    # 数据提取 - 净利润
    col_fzb_main = []
    col_fzb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_fzb_main << m[44]
      end
    end
    # 数据提取 - 营业收入
    col_zcb_main = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main << m[54]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = col_fzb_main[i].to_f / col_zcb_main[i].to_f * 100
      result << m.round(2)
    end
    # 返回负债占资产比率
    return result
  end

  # --- D2、长期负债占不动产/厂房及设备比率 ---
  # =  (长期负债 fzb43 + 股东权益 gdb15) / 固定资产 zcb39
  def long_term_funds_for_fixed_assets_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_fzb = JSON.parse(self.fzb)
    col_gdb = JSON.parse(self.gdb)
    col_zcb = JSON.parse(self.zcb)
    # 数据提取 - 长期负债
    col_fzb_main = []
    col_fzb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_fzb_main << m[43]
      end
    end
    # 数据提取 - 股东权益
    col_gdb_main = []
    col_gdb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_gdb_main << m[15]
      end
    end
    # 数据提取 - 固定资产
    col_zcb_main = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main << m[39]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = ( col_fzb_main[i].to_f + col_gdb_main[i].to_f ) / col_zcb_main[i].to_f * 100
      result << m.round(2)
    end
    # 长期资金占不动产/厂房及设备比率
    return result
  end

  # --- E1、流动比率 ---
  # =  流动资产 zcb27 / 流动负债 fzb34
  def current_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_zcb = JSON.parse(self.zcb)
    col_fzb = JSON.parse(self.fzb)
    # 数据提取 - 流动资产
    col_zcb_main = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main << m[27]
      end
    end
    # 数据提取 - 流动负债
    col_fzb_main = []
    col_fzb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_fzb_main << m[34]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = col_zcb_main[i].to_f / col_fzb_main[i].to_f * 100
      result << m.round(2)
    end
    # 流动比率
    return result
  end

  # --- E2、速动比率 ---
  # =  流动资产 zcb27 - 存货 zcb22 - 预付款项 zcb10 / 流动负债 fzb34
  def quick_ratio(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_zcb = JSON.parse(self.zcb)
    col_fzb = JSON.parse(self.fzb)
    # 数据提取 - 流动资产
    col_zcb_main_1 = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main_1 << m[27]
      end
    end
    # 数据提取 - 存货
    col_zcb_main_2 = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main_2 << m[22]
      end
    end
    # 数据提取 - 预付款项
    col_zcb_main_3 = []
    col_zcb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_zcb_main_3 << m[10]
      end
    end
    # 数据提取 - 净利润
    col_fzb_main = []
    col_fzb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_fzb_main << m[34]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = ( col_zcb_main_1[i].to_f - col_zcb_main_2[i].to_f - col_zcb_main_3[i].to_f ) / col_fzb_main[i].to_f * 100
      result << m.round(2)
    end
    # 流动比率
    return result
  end

  # --- F1、经营活动现金流量(百万元) ---
  # =  经营活动产生现金流量净额(万元) lrb83
  def net_cash_flow_of_business_activities(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_llb = JSON.parse(self.llb)
    # 数据提取 - 净利润
    col_llb_main = []
    col_llb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_llb_main << m[83]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = col_llb_main[i].to_f / 100
      result << m.round(0)
    end
    # 返回经营活动现金流量
    return result
  end

  # --- F2、投资活动现金流量(百万元) ---
  # =  投资活动产生现金流量净额(万元) lrb42
  def net_investment_activities_generated_cash_flow(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_llb = JSON.parse(self.llb)
    # 数据提取 - 净利润
    col_llb_main = []
    col_llb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_llb_main << m[42]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = col_llb_main[i].to_f / 100
      result << m.round(0)
    end
    # 返回投资活动现金流量
    return result
  end

  # --- F2、筹资活动现金流量(百万元) ---
  # =  筹资活动产生的现金流量净额(万元) lrb54
  def net_financing_activities_generated_cash_flow(time)
    # 数据源
    if time == 10
      years = self.quarter_years[0..9]
    elsif time == 5
      years = self.quarter_years[0..4]
    elsif time == 2
      years = self.quarter_recent
    end
    col_llb = JSON.parse(self.llb)
    # 数据提取 - 净利润
    col_llb_main = []
    col_llb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
        col_llb_main << m[54]
      end
    end
    # 运算
    result = []
    (0..time-1).each do |i|
      m = col_llb_main[i].to_f / 100
      result << m.round(0)
    end
    # 返回筹资活动现金流量
    return result
  end


# -----------------------------------数据排序算法脚本-----------------------------------

  # 最新年度现金流量排序
  def cash_order
    self.cash_and_cash_equivalents_ratio(5)[0]
  end

  # 最新年度毛利率排序
  def operating_margin_order
   self.operating_margin_ratio(5)[0]
  end

  # 最新年度净利率排序
  def net_profit_margin_order
   self.net_profit_margin_ratio(5)[0]
  end

  #股东权益报酬率 RoE 排序
  def roe_order
    self.roe_ratio(5)[0]
  end

  #负债占资本利率排序
  def debt_asset_order
    self.debt_asset_ratio(5)[0]
  end

end
