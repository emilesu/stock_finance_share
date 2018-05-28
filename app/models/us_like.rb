class UsLike < ApplicationRecord
  belongs_to :user
  belongs_to :us_note
end
