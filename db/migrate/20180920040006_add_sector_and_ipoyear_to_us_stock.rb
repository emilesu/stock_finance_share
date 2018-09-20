class AddSectorAndIpoyearToUsStock < ActiveRecord::Migration[5.1]
  def change
    add_column :us_stocks, :sector, :string
    add_column :us_stocks, :ipoyear, :string
  end
end
