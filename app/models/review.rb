class Review < ApplicationRecord

  # 资料验证
  validates_presence_of :content

  belongs_to :user
  belongs_to :twitter

end
