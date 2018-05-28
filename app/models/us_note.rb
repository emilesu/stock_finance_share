class UsNote < ApplicationRecord

  # 与 user, stock 关系
  belongs_to :user
  belongs_to :us_stock

  # 资料验证
  validates_presence_of :title, :level, :status

  LEVEL = ["等待入场", "近期关注", "长期关注"]
  validates_inclusion_of :level, :in => LEVEL

  STATUS = ["公开", "对会员公开", "私密"]
  validates_inclusion_of :status, :in => STATUS

  # 与 us_like 关系
  has_many :us_likes, :dependent => :destroy
  has_many :liked_users, :through => :us_likes, :source => :user

  def find_us_like(user)
    self.us_likes.where( :user_id => user.id ).first
  end

end
