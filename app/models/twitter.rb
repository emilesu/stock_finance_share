class Twitter < ApplicationRecord

  # 资料验证
  validates_presence_of :content

  belongs_to :user
  has_many :reviews, :dependent => :destroy

  TWITTER_STATUS = ["公开", "私密"]
  validates_inclusion_of :status, :in => TWITTER_STATUS

end
