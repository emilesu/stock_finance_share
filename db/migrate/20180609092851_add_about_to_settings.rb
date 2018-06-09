class AddAboutToSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :settings, :about, :text
  end
end
