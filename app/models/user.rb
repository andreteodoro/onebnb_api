class User < ActiveRecord::Base
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User

  mount_base64_uploader :photo, PhotoUploader
  enum kind: [ :user, :admin ]
  enum gender: [ :homem, :mulher ]

  belongs_to :address

  has_many :wishlists, dependent: :destroy
  has_many :talks, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :properties, dependent: :destroy
end
