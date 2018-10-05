class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable,
         :omniauth_providers => [:wechat, :google_oauth2, :facebook, :github]

  # <---- 微信登入回调数据处理 ---->
  # 微信登陆识别表福
  has_many :identifies, :dependent => :destroy
  # </---- 微信登入回调数据处理 ---->

  # 资料验证
  validates_presence_of :username, :role
  validates :username, presence: true, length: {maximum: 25}

  # 用户权限等级
  ROLE = ["admin", "member", "nonmember"]
  validates_inclusion_of :role, :in => ROLE

  # 用户点击选择股票上市年限按钮 time_range的时间范围
  TIME_RANGE = ["all_years", "three_years", "five_years"]
  validates_inclusion_of :time_range, :in => TIME_RANGE

  # 与 note 关系
  has_many :notes

  # 与 us_notes 关系
  has_many :us_notes

  # 与 trade 关系
   has_many :trades

  # 与 us_trade 关系
  has_many :us_trades

  # 与 like 关系
  has_many :likes, :dependent => :destroy
  has_many :liked_notes, :through => :likes, :source => :note

  # 与 us_like 关系
  has_many :us_likes, :dependent => :destroy
  has_many :liked_su_notes, :through => :us_likes, :source => :us_note

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

  #浏览量易受器
  is_impressionable

  # avatar 头像上传
  # mount_uploader :avatar, AvatarUploader

  # :level去重函数 A股, 在 user/show页面用到
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

  # :level去重函数 美股, 在 user/show页面用到
  def us_level_uniq(level)
    notes = []
    self.us_notes.where(:level => level).order("created_at DESC").each do |i|
      notes << i
    end
    stocks = []
    notes.each do |i|
      stocks << i.us_stock
    end
    return stocks.uniq
  end


  # google登录的from_google方法，用于omniauth_callbacks_controller.rb中
  # def self.from_google(access_token, signed_in_resource=nil)
  #   data = access_token.info
  #   identify = Identify.find_by(:provider => access_token.provider, :uid => access_token.uid)
  #
  #   if identify
  #       return identify.user
  #   else
  #       user = User.find_by(:email => access_token.email)
  #       if !user
  #           user = User.create(
  #               username: data["name"],
  #               email: data["email"],
  #               avatar: data["image"],
  #               password: Devise.friendly_token[0,20]
  #           )
  #       end
  #           identify = Identify.create(
  #               provider: access_token.provider,
  #               uid: access_token.uid,
  #               user: user
  #           )
  #       return user
  #   end
  # end


  # facebook登录的from_facebook方法，用于omniauth_callbacks_controller.rb中
  # def self.from_facebook(access_token, signed_in_resoruce=nil)
  #   data = access_token.info
  #   identify = Identify.find_by(provider: access_token.provider, uid: access_token.uid)
  #
  #   if identify
  #       return identify.user
  #   else
  #       user = User.find_by(:email => data.email)
  #       if !user
  #           i = Devise.friendly_token[0,20]
  #           user = User.create(
  #               username: access_token.extra.raw_info.name,
  #               email: data.email,
  #               avatar: data.image,
  #               password: i,
  #               password_confirmation: i
  #           )
  #       end
  #       identify = Identify.create(
  #           provider: access_token.provider,
  #           uid: access_token.uid,
  #           user: user
  #       )
  #       return user
  #   end
  # end


  def self.from_github(access_token, signed_in_resoruce=nil)
    data = access_token["info"]
    identify = Identify.find_by(provider: access_token["provider"], uid: access_token["uid"])

    if identify
      return identify.user
    else
      user = User.find_by(:email => data["email"])
      if !user
          if data["name"].nil?
              name = data["nickname"]
          else
              name = data["name"]
          end
          i = Devise.friendly_token[0,20]
          user = User.create(
              username: name,
              email: data["email"],
              avatar: data["image"],
              password: Devise.friendly_token[0,20],
              # password_confirmation: i
          )
      end

      identify = Identify.create(
          provider: access_token["provider"],
          uid: access_token["uid"],
          user: user
      )

      return user
    end
  end


end
