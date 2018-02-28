class Course < ApplicationRecord
  # 与 post 关系
  has_many :posts, :dependent => :destroy

  # 资料验证
  validates_presence_of :title, :desctiption
end
