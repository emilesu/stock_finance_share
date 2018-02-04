class AddVersionToStock < ActiveRecord::Migration[5.1]
  def change
    add_column :stocks, :version, :integer
  end
  Stock.all.each do |s|
    if s.lrb && s.llb && s.zcb != nil
      s.update!(
        :version => 1
      )
    end
  end
end
