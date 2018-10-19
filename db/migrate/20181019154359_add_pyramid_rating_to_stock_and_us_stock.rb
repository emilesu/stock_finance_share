class AddPyramidRatingToStockAndUsStock < ActiveRecord::Migration[5.1]
  def change
    add_column :stocks, :pyramid_rating, :integer
    add_column :us_stocks, :pyramid_rating, :integer
  end
end
