class AddDatatableToStock < ActiveRecord::Migration[5.1]
  def change
    add_column :stocks, :lrb, :string           #利润表
    add_column :stocks, :llb, :string           #现金流量表
    add_column :stocks, :zcb, :string           #资产负债表资产部分
    add_column :stocks, :fzb, :string           #资产负债表负债部分
    add_column :stocks, :gdb, :string           #资产负债表股东权益部分
    add_column :stocks, :industry, :string      #股票行业分类
    add_index :stocks, :industry
  end
end
