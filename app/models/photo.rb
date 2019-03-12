class Photo < ApplicationRecord
  validates :user_id, presence: true
  validates :image, presence: true
  mount_uploader :image, PhotoUploader
end
