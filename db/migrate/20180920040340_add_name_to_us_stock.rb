class AddNameToUsStock < ActiveRecord::Migration[5.1]
  def change
    add_column :us_stocks, :name, :string
  end
end
