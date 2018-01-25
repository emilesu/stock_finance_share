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


  # 年度数据
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
    # 返回最近5年的年份
    return year_all
  end

  # --- A1-1、现金流量比率（  >100%比较好 ）---
  # =  营业活动现金流量llb27  /  流动负债fzb34
  def operating_cash_flow_ratio
    # 数据源
    years = self.quarter_years[0..4].reverse
    col_llb = JSON.parse(self.llb).reverse
    col_fzb = JSON.parse(self.fzb).reverse
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
    (0..years.count-1).each do |i|
      m = col_llb_main[i].to_f / col_fzb_main[i].to_f * 100
      result << eval(sprintf("%8.2f",m))
    end
    # 返回最近5年现金流量比率
    return result
  end

  # --- A1-2、现金流量允当比率（  >100%比较好 ）---
  # =  最近5年营业活动现金流量llb27  /  最近5年  (  资本支出llb35  + 存货增加额-llb77 + 现金股利llb50   )
  def cash_flow_adequancy_ratio
    # 数据源
    years = self.quarter_years
    col_llb = JSON.parse(self.llb).reverse
    # 数据提取 - col_llb_main_1(营业活动现金流量)\col_llb_main_2(资本支出)\col_llb_main_3(存货增加额)\col_llb_main_4(现金股利)
    col_llb_main_1 = []
    col_llb_main_2 = []
    col_llb_main_3 = []
    col_llb_main_4 = []
    col_llb.each do |i|
      m = i.split(",")
      if years.include?(m[2])
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
    (1..years.count-4).each do |i|
      c1 << col_llb_main_1[-i].to_f + col_llb_main_1[-i-1].to_f + col_llb_main_1[-i-2].to_f + col_llb_main_1[-i-3].to_f + col_llb_main_1[-i-4].to_f
      c2 << col_llb_main_2[-i].to_f + col_llb_main_2[-i-1].to_f + col_llb_main_2[-i-2].to_f + col_llb_main_2[-i-3].to_f + col_llb_main_2[-i-4].to_f
      c3 << col_llb_main_3[-i].to_f + col_llb_main_3[-i-1].to_f + col_llb_main_3[-i-2].to_f + col_llb_main_3[-i-3].to_f + col_llb_main_3[-i-4].to_f
      c4 << col_llb_main_4[-i].to_f + col_llb_main_4[-i-1].to_f + col_llb_main_4[-i-2].to_f + col_llb_main_4[-i-3].to_f + col_llb_main_4[-i-4].to_f
    end
    result = []
    (0..c1.count-1).each do |i|
      m = c1[i] * 100 / (c2[i] - c3[i] + c4[i])
      result << eval(sprintf("%8.2f",m))
    end
    # 返回最近5年现金流量比率
    return result
  end

  # --- A1-3、现金再投资比率（  >10%比较好 ）---
  # =  营业活动现金流量llb27 - 现金股利llb50  /  固定资产毛额  + 长期投资 + 其他资产 + 营运资金 ==> 分母等同于 资产总额zcb54 - 流动负债fzb34
  def cash_re_investment_ratio
    #code
  end


end
