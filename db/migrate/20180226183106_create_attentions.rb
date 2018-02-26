class CreateAttentions < ActiveRecord::Migration[5.1]
  def change
    create_table :attentions do |t|
      t.integer :user_id, :index => true
      t.integer :my_attention, :index => true
      t.timestamps
    end
  end
end
