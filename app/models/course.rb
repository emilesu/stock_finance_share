class Course < ApplicationRecord
  # 与 post 关系
  has_many :posts, :dependent => :destroy

  # 资料验证
  validates_presence_of :title, :desctiption, :friendly_id
  validates_uniqueness_of :friendly_id
  validates_format_of :friendly_id, :with => /\A[a-z0-9\-]+\z/

  # 修改网址显示
  def to_param
    self.friendly_id
  end


end
