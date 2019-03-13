class HomelandPost < ApplicationRecord

  # 与 user, homeland_posts 的关系
  belongs_to :user
  belongs_to :homeland

  # 资料验证
  validates_presence_of :description

  # 与 homeland_like 的关系
  has_many :homeland_post_likes, :dependent => :destroy
  has_many :homeland_post_liked_users, :through => :homeland_post_likes, :source => :user

  def find_homeland_post_like(user)
    self.homeland_post_likes.where( :user_id => user.id ).first
  end

end
