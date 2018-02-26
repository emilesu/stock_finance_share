class CreateFans < ActiveRecord::Migration[5.1]
  def change
    create_table :fans do |t|
      t.integer :user_id, :index => true
      t.integer :my_fans, :index => true
      t.timestamps
    end
  end
end
