class Note < ApplicationRecord

  # 与 user, stock 关系
  belongs_to :user
  belongs_to :stock

  # 资料验证
  validates_presence_of :title, :level, :status

  LEVEL = ["等待入场", "近期关注", "长期关注"]
  validates_inclusion_of :level, :in => LEVEL

  STATUS = ["公开", "对会员公开", "私密"]
  validates_inclusion_of :status, :in => STATUS

  # 与 like 关系
  has_many :likes, :dependent => :destroy
  has_many :liked_users, :through => :likes, :source => :user

  def find_like(user)
    self.likes.where( :user_id => user.id ).first
  end

end
