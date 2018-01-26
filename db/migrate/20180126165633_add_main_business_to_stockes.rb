class AddMainBusinessToStockes < ActiveRecord::Migration[5.1]
  def change
    add_column :stocks, :main_business, :string
  end
end
