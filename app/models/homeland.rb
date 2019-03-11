class Homeland < ApplicationRecord

  # 与 user, homeland_posts 的关系
  belongs_to :user
  has_many :homeland_posts, :dependent => :destroy

  # 资料验证
  validates_presence_of :title, :description, :categories

  CATEGORIES = ["学习", "股票", "反馈", "公告"]
  validates_inclusion_of :categories, :in => CATEGORIES

end
