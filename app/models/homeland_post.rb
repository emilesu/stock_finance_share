class HomelandPost < ApplicationRecord

  # 与 user, homeland_posts 的关系
  belongs_to :user
  belongs_to :homeland

  # 资料验证
  validates_presence_of :description

end
