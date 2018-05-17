class Post < ApplicationRecord
  # 与 course 关系
  belongs_to :course

  # 资料验证
  # validates_presence_of :title, :description, :catalog, :section

  STATUS = ["draft", "member", "public"]
  validates_inclusion_of :status, :in => STATUS

end
