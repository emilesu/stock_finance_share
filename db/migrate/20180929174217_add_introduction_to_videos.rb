class AddIntroductionToVideos < ActiveRecord::Migration[5.1]
  def change
    add_column :videos, :introduction, :text
  end
end
