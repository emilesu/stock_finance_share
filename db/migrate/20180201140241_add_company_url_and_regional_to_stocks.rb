class AddCompanyUrlAndRegionalToStocks < ActiveRecord::Migration[5.1]
  def change
    add_column :stocks, :company_url, :string
    add_column :stocks, :regional, :string
  end
end
