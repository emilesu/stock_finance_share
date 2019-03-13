class HomelandPostLike < ApplicationRecord
  belongs_to :user
  belongs_to :homeland_post
end
