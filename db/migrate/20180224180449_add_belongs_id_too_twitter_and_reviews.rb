class AddBelongsIdTooTwitterAndReviews < ActiveRecord::Migration[5.1]
  def change
    add_column :twitters, :user_id, :string
    add_index :twitters, :user_id
    add_column :reviews, :user_id, :string
    add_column :reviews, :twitter_id, :string
    add_index :reviews, :user_id
    add_index :reviews, :twitter_id
  end
end
