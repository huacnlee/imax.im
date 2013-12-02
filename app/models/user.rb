# coding: utf-8
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ## Database authenticatable
  field :email,              :type => String, :null => false, :default => ""
  field :encrypted_password, :type => String, :null => false, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  field :name
  field :bio
  field :website
  field :verified, :type => Boolean, :default => false

  attr_accessor :captcha

  mount_uploader :avatar, AvatarUploader

  validates_uniqueness_of :name

  index :name
  index :email

  def to_s
    self.name
  end

  def avatar_small_url
    self.avatar.url(:normal)
  end

  # 是否是管理员
  def admin?
    Setting.admin_emails.include?(self.email)
  end

  # 是否可信
  def verified?
    self.admin? or self.verified == true
  end

  def update_with_password(params={})
    if !params[:current_password].blank? or !params[:password].blank? or !params[:password_confirmation].blank?
      super
    else
      params.delete(:current_password)
      self.update_without_password(params)
    end
  end

  def admin?
    self.email.in?(Setting.admin_emails)
  end

  def self.find_by_username(s)
    where(name: s).first
  end
end
