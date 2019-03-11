class AddHomelandDefault < ActiveRecord::Migration[5.1]
  def change
    change_column :homelands, :categories, :string, :default => "学习"
    add_column :homelands, :status, :string, :default => "公开"
    add_column :users, :homeland_role, :string, :default => "可发言"

    User.find_each do |i|
      i.update(:homeland_role => "可发言")
    end
  end
end
