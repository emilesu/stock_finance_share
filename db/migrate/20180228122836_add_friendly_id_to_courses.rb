class AddFriendlyIdToCourses < ActiveRecord::Migration[5.1]
  def change
    add_column :courses, :friendly_id, :string
    add_index :courses, :friendly_id, :unique => true
  end
end
