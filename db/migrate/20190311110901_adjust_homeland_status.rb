class AdjustHomelandStatus < ActiveRecord::Migration[5.1]
  def change
    add_index :homelands, :status
  end
end
