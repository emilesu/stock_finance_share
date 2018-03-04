class AddStatusTooPost < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :status, :string, :default => "draft"
  end
end
