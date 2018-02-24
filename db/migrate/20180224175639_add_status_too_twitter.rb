class AddStatusTooTwitter < ActiveRecord::Migration[5.1]
  def change
    add_column :twitters, :status, :string, :default => "公开"
  end
end
