class Video < ApplicationRecord

  validates_presence_of :title, :introduction, :description, :cover

end
