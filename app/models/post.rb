class Post < ApplicationRecord
  # 与 course 关系
  belongs_to :course

  # 资料验证
  validates_presence_of :title, :desctiption, :catalog, :section
end
