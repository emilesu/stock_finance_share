class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # 资料验证
  validates_presence_of :username, :role

  # 用户权限等级
  ROLE = ["admin", "member", "nonmember"]
  validates_inclusion_of :role, :in => ROLE

  # 用户点击选择股票上市年限按钮 time_range的时间范围
  TIME_RANGE = ["all_years", "three_years", "five_years"]
  validates_inclusion_of :time_range, :in => TIME_RANGE

  # 与 note 关系
  has_many :notes

  # 与 like 关系
  has_many :likes, :dependent => :destroy
  has_many :liked_notes, :through => :likes, :source => :note

  # ---把网址改成用户名---
  def to_param
    self.username
  end

  # avatar 头像上传
  # mount_uploader :avatar, AvatarUploader

  # :level去重函数, 在 user/show页面用到
  def level_uniq(level)
    notes = []
    self.notes.where(:level => level).order("created_at DESC").each do |i|
      notes << i
    end
    stocks = []
    notes.each do |i|
      stocks << i.stock
    end
    return stocks.uniq
  end

end
