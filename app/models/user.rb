class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :omniauthable,
         :omniauth_providers => [:wechat]
         # , :validatable

  # <---- 微信登入回调数据处理 ---->
  # 微信登陆识别表福
  has_many :identifies

  def self.from_wechat(access_token, signed_in_resoruce=nil)
    data = access_token.info
    identify = Identify.find_by(provider: access_token.provider, uid: access_token.uid)

    if identify
      return identify.user
    else
      user = User.find_by(:email => data.email)
      if !user
        user = User.create(
          username: access_token.extra.raw_info.name,
          email: data.email,
          avatar: data.image,
          password: Devise.friendly_token[0,20]
        )
      end
      identify = Identify.create(
        provider: access_token.provider,
        uid: access_token.uid,
        user: user
      )
      return user
    end
  end
  # </---- 微信登入回调数据处理 ---->

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

  # 与 twitter 和 review 关系
  has_many :twitters, :dependent => :destroy
  has_many :reviews, :dependent => :destroy

  # 与 fan 和 attention 关系
  has_many :fans, :dependent => :destroy
  has_many :attentions, :dependent => :destroy

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
